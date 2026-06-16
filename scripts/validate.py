#!/usr/bin/env python3
"""Validate the shared Copilot configuration pack."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple

ROOT = Path(__file__).resolve().parent.parent
SHARED_GITHUB = ROOT / "shared" / ".github"
REQUIRED_SUBDIRS = ("agents", "instructions", "prompts", "skills")
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.S)
KEY_RE = re.compile(r"^(\w[\w-]*):", re.M)


class ValidationError(Exception):
	"""Raised when a configuration artifact cannot be validated."""


def parse_frontmatter(path: Path) -> Tuple[Set[str], str]:
	text = path.read_text(encoding="utf-8")
	match = FRONTMATTER_RE.match(text)
	if not match:
		raise ValidationError(f"missing YAML frontmatter: {path}")
	frontmatter = match.group(1)
	keys = set(KEY_RE.findall(frontmatter))
	return keys, frontmatter


def extract_scalar(frontmatter: str, key: str) -> Optional[str]:
	match = re.search(rf"^{re.escape(key)}:\s*(.+)$", frontmatter, re.M)
	if not match:
		return None
	return match.group(1).strip().strip('"\'')


def extract_indented_block(frontmatter: str, key: str) -> Optional[str]:
	match = re.search(rf"^{re.escape(key)}:\s*\n((?:[ \t].*(?:\n|$))*)", frontmatter, re.M)
	if not match:
		return None
	return match.group(1)


def extract_handoff_agents(frontmatter: str) -> List[str]:
	block = extract_indented_block(frontmatter, "handoffs")
	if not block:
		return []
	return [
		value.strip().strip('"\'')
		for value in re.findall(r"^\s+agent:\s*(.+)$", block, re.M)
	]


def count_yaml_list_items(block: Optional[str]) -> int:
	if not block:
		return 0
	return len(re.findall(r"^\s*-\s+", block, re.M))


def check_required_keys(
	path: Path, required_keys: Iterable[str], errors: List[str]
) -> Optional[Tuple[Set[str], str]]:
	try:
		keys, frontmatter = parse_frontmatter(path)
	except ValidationError as exc:
		errors.append(str(exc))
		return None

	missing = [key for key in required_keys if key not in keys]
	if missing:
		errors.append(f"missing {', '.join(missing)} in {path}")
	return keys, frontmatter


def check_for_symlinks(base_dir: Path, errors: List[str]) -> None:
	for path in sorted(base_dir.rglob("*")):
		if path.is_symlink():
			errors.append(f"symlink artifacts are not allowed: {path}")


def main() -> int:
	errors: List[str] = []

	if not SHARED_GITHUB.is_dir():
		errors.append(f"missing source directory: {SHARED_GITHUB}")
	else:
		for name in REQUIRED_SUBDIRS:
			subdir = SHARED_GITHUB / name
			if not subdir.is_dir():
				errors.append(f"missing expected directory: {subdir}")
		check_for_symlinks(SHARED_GITHUB, errors)

	agent_names: Dict[str, Path] = {}
	agent_ids: Dict[str, Path] = {}
	agent_records: List[Tuple[Path, Set[str], str]] = []

	agents_dir = SHARED_GITHUB / "agents"
	if agents_dir.is_dir():
		for path in sorted(agents_dir.glob("*.agent.md")):
			result = check_required_keys(path, ("name", "description", "tools"), errors)
			if not result:
				continue
			_, frontmatter = result
			name = extract_scalar(frontmatter, "name")
			if not name:
				errors.append(f"missing parseable name in {path}")
				continue
			if name in agent_names:
				errors.append(
					f"duplicate agent name {name!r} in {path} and {agent_names[name]}"
				)
				continue
			agent_names[name] = path
			agent_ids[path.name[: -len(".agent.md")]] = path
			agent_records.append((path, _, frontmatter))

	for path, keys, frontmatter in agent_records:
		if "handoffs" not in keys:
			continue
		handoff_block = extract_indented_block(frontmatter, "handoffs")
		handoff_agents = extract_handoff_agents(frontmatter)
		if count_yaml_list_items(handoff_block) > len(handoff_agents):
			errors.append(f"missing parseable handoff agent reference in {path}")
		for agent in handoff_agents:
			if agent not in agent_names and agent not in agent_ids:
				errors.append(f"unknown handoff agent {agent!r} in {path}")

	instructions_dir = SHARED_GITHUB / "instructions"
	if instructions_dir.is_dir():
		for path in sorted(instructions_dir.glob("*.instructions.md")):
			check_required_keys(path, ("description", "applyTo"), errors)

	prompts_dir = SHARED_GITHUB / "prompts"
	if prompts_dir.is_dir():
		for path in sorted(prompts_dir.glob("*.prompt.md")):
			result = check_required_keys(path, ("name", "description", "agent"), errors)
			if not result:
				continue
			_, frontmatter = result
			agent = extract_scalar(frontmatter, "agent")
			if not agent:
				errors.append(f"missing parseable agent reference in {path}")
			elif agent not in agent_names:
				errors.append(f"unknown prompt agent {agent!r} in {path}")

	skills_dir = SHARED_GITHUB / "skills"
	if skills_dir.is_dir():
		for path in sorted(skills_dir.glob("*/SKILL.md")):
			check_required_keys(path, ("name", "description"), errors)

	if errors:
		print("Validation failed:", file=sys.stderr)
		for error in errors:
			print(f"- {error}", file=sys.stderr)
		return 1

	print("Validation passed.")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())

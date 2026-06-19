#!/usr/bin/env python3
"""Validate the shared Copilot configuration pack and local mirror files."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple

ROOT = Path(__file__).resolve().parent.parent
ROOT_GITHUB = ROOT / ".github"
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


def collect_agent_records(
	agents_dir: Path, errors: List[str]
) -> Tuple[Dict[str, Path], Dict[str, Path], List[Tuple[Path, Set[str], str]]]:
	agent_names: Dict[str, Path] = {}
	agent_ids: Dict[str, Path] = {}
	agent_records: List[Tuple[Path, Set[str], str]] = []

	if not agents_dir.is_dir():
		return agent_names, agent_ids, agent_records

	for path in sorted(agents_dir.glob("*.agent.md")):
		result = check_required_keys(path, ("name", "description"), errors)
		if not result:
			continue
		keys, frontmatter = result
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
		agent_records.append((path, keys, frontmatter))

	return agent_names, agent_ids, agent_records


def validate_agent_handoffs(
	agent_names: Dict[str, Path],
	agent_ids: Dict[str, Path],
	agent_records: List[Tuple[Path, Set[str], str]],
	errors: List[str],
) -> None:
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


def validate_instructions_dir(instructions_dir: Path, errors: List[str]) -> None:
	if not instructions_dir.is_dir():
		return

	for path in sorted(instructions_dir.glob("*.instructions.md")):
		check_required_keys(path, ("description", "applyTo"), errors)


def validate_prompts_dir(
	prompts_dir: Path, agent_names: Dict[str, Path], errors: List[str]
) -> None:
	if not prompts_dir.is_dir():
		return

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


def validate_skills_dir(skills_dir: Path, errors: List[str]) -> None:
	if not skills_dir.is_dir():
		return

	for path in sorted(skills_dir.glob("*/SKILL.md")):
		check_required_keys(path, ("name", "description"), errors)


def check_root_mirrors(root_github: Path, shared_github: Path, errors: List[str]) -> None:
	for subdir, pattern in (("agents", "*.agent.md"), ("prompts", "*.prompt.md")):
		root_dir = root_github / subdir
		shared_dir = shared_github / subdir
		if not root_dir.is_dir() or not shared_dir.is_dir():
			continue
		for root_path in sorted(root_dir.glob(pattern)):
			shared_path = shared_dir / root_path.name
			if not shared_path.is_file():
				continue
			if root_path.read_text(encoding="utf-8") != shared_path.read_text(
				encoding="utf-8"
			):
				errors.append(f"root mirror drift: {root_path} does not match {shared_path}")


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

	agent_names, agent_ids, agent_records = collect_agent_records(
		SHARED_GITHUB / "agents", errors
	)
	validate_agent_handoffs(agent_names, agent_ids, agent_records, errors)
	validate_instructions_dir(SHARED_GITHUB / "instructions", errors)
	validate_prompts_dir(SHARED_GITHUB / "prompts", agent_names, errors)
	validate_skills_dir(SHARED_GITHUB / "skills", errors)

	root_agent_names, root_agent_ids, root_agent_records = collect_agent_records(
		ROOT_GITHUB / "agents", errors
	)
	validate_agent_handoffs(root_agent_names, root_agent_ids, root_agent_records, errors)
	validate_instructions_dir(ROOT_GITHUB / "instructions", errors)
	validate_prompts_dir(ROOT_GITHUB / "prompts", root_agent_names, errors)
	check_root_mirrors(ROOT_GITHUB, SHARED_GITHUB, errors)

	if errors:
		print("Validation failed:", file=sys.stderr)
		for error in errors:
			print(f"- {error}", file=sys.stderr)
		return 1

	print("Validation passed.")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())

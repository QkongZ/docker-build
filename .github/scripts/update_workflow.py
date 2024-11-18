from pathlib import Path

WORKFLOW_FILE = Path('.github/workflows/docker-build.yml')

def get_project_folders():
    """扫描根目录下的所有项目文件夹，排除非项目文件夹"""
    root = Path.cwd()
    exclude_dirs = {'.github', '.git'}
    projects = [
        f.name.lower() for f in root.iterdir()
        if f.is_dir() and f.name not in exclude_dirs and (f / 'Dockerfile').exists()
    ]
    return projects

def update_workflow(projects):
    """更新 Workflow 文件中的 paths 和 matrix 部分"""
    with WORKFLOW_FILE.open('r') as f:
        workflow = f.read()

    # 替换 paths 部分
    paths_block = '\n'.join(f"      - '{project}/**'" for project in projects)
    workflow = replace_block(workflow, 'paths:', paths_block)

    # 替换 matrix 部分
    matrix_block = f"folder: [{', '.join(projects)}]"
    workflow = replace_block(workflow, 'matrix:', matrix_block)

    # 写回更新后的 Workflow 文件
    with WORKFLOW_FILE.open('w') as f:
        f.write(workflow)

def replace_block(workflow, block_start, new_content):
    """替换指定块的内容"""
    lines = workflow.splitlines()
    start_index = next(i for i, line in enumerate(lines) if line.strip().startswith(block_start))
    indent = ' ' * (len(lines[start_index]) - len(lines[start_index].lstrip()))
    
    # 找到块的结束位置（下一个空行或下一部分开始）
    end_index = start_index + 1
    while end_index < len(lines) and (lines[end_index].startswith(indent + '-') or lines[end_index].strip() == ''):
        end_index += 1

    new_block = f"{block_start}\n{new_content}"
    return '\n'.join(lines[:start_index] + [new_block] + lines[end_index:])

def main():
    projects = get_project_folders()
    print(f"识别到的项目文件夹：{projects}")
    update_workflow(projects)
    print("Workflow 文件更新完成！")

if __name__ == "__main__":
    main()

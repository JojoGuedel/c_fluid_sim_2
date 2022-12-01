import os
import sys

class Path():
    def __init__(self, name, parent = None, *children):
        self.name = name
        self.parent = parent
        self.children = list(children)

    def __str__(self):
        prefix = "Path"

        if self.is_folder():
            prefix = "Folder"
        elif self.is_file():
            prefix = "File"

        return f"{prefix}: {self.name}"

    def __repr__(self):
        return str(self)
    
    def is_folder(self):
        return os.path.isdir(self.full_path())
    
    def is_file(self):
        return os.path.isfile(self.full_path())

    def full_path(self):
        if self.parent != None:
            return self.parent.full_path() + "/" + self.name
        
        if os.name == "nt":
            return self.name
        elif os.name == "posix":
            return "/" + self.name

    def exists(self):
        return os.path.exists(self.full_path())
    
    def root(self):
        if self.parent is not None:
            return self.parent.root()
        else:
            return self

    def print(self, indent = "", is_last = True):
        marker = "└──" if is_last else "├──"
        print(indent + marker + str(self))

        indent += "    " if is_last else "│   "
        for i, child in enumerate(self.children):
            child.print(indent, i == len(self.children) - 1)
    
    @staticmethod
    def parse(path: str):
        if os.path.exists(path):
            path = os.path.abspath(path)

        path = path.replace("\\", "/")
        path_split = path.split("/")


        if len(path_split) == 0:
            return None
        
        root = Path("")
        last = root

        for i in path_split:
            if len(i) != 0:
                child = Path(i, last if len(last.name) != 0 else None)
                last.children.append(child)
                last = child

        return last
    
    @staticmethod
    def read(path, recursive = False):
        if len(path.children) != 0:
            return None

        if path.exists():
            for i in os.scandir(path.full_path()):
                child = Path(i.name, path)
                path.children.append(child)

                if recursive:
                    child = Path.read(child)

            return path

        else:
            return None

PIXA_LIB_WIN = "pixa32s"
PIXA_LIB_LIN = "libpixa.a"

def build_cmd(program: str, src_files: list[str], inc_path: str = None, out_path: str = None, lib_path: str = None, libs: list[str] = None, definitions: list[str] = None, additional_args: list[str] = None):
    cmd = program

    for i in src_files:
        if i:
            cmd += f" {i}"
    
    if inc_path:
        cmd += f" -I{inc_path}"
    if out_path:
        cmd += f" -o{out_path}"

    if lib_path:
        cmd += f" -L{lib_path}"
    if libs:
        for i in libs:
            if i:
                cmd += f" -l{i}"
    
    if definitions:
        for i in definitions:
            if i:
                cmd += f" -D{i}"
    if additional_args:
        for i in additional_args:
            if i:
                cmd += f" {i}"
    
    return cmd


class Win:
    @staticmethod
    def build(debug):
        src_files = [f"{workspace_dir.full_path()}/src/*.c", f"{workspace_dir.full_path()}/src/Utils/*.c"]
        inc_path = f"{workspace_dir.full_path()}/inc"

        lib_path = f"{workspace_dir.full_path()}/lib/windows"
        libs = ["User32", "Gdi32", "Shell32", "opengl32", "glfw3_mt", "glew32s", PIXA_LIB_WIN]

        out_path = Path.parse(f"{workspace_dir.full_path()}/out/windows/{workspace_dir.name}.exe")

        if not out_path.parent.exists():
            create = []
            last = out_path.parent

            while not last.exists():
                create.append(last.full_path())
                last = last.parent
            
            create.reverse()

            for i in create:
                os.mkdir(i)
        
        definitions = ["DEBUG"] if debug else None
        additional_args = ["-g" if debug else None, "-O0" if debug else "-O3", "-Wall", "-fsanitize=address", "-fno-omit-frame-pointer"] #, "-Wno-deprecated-declarations"]

        cmd = build_cmd("clang", src_files, inc_path, out_path.full_path(), lib_path, libs, definitions, additional_args)

        print(f"Executing: {cmd}")
        ret = os.system(cmd)

def print_help():
    print("USAGE: python [path to build.py] [options]")
    print()
    print("OPTIONS:")
    print("  build ([mode=d/r])")
    print("          build in (d)ebug or (r)eleaser. Default mode is debug")

def main():
    global workspace_dir

    if len(sys.argv) < 2:
        print_help()
        return

    workspace_dir = Path.parse(sys.argv[0]).parent
    
    if sys.argv[1] == "build":
        debug = True

        if len(sys.argv) == 3:
            if sys.argv[2] == "d":
                debug = True
            elif sys.argv[2] == "r":
                debug = False
            else:
                print_help()
                return

        if os.name == "nt":
            Win.build(debug)
        else:
            print(f"Platform '{os.name}' not suportet!")
            return

if __name__ == "__main__":
    main()

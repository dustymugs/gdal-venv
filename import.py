import argparse
from pathlib import Path
from shutil import copytree, rmtree
import tempfile

from sh import wget, tar, python, find
from packaging.version import parse as parse_version

parser = argparse.ArgumentParser()
parser.add_argument("version")


if __name__ == "__main__":
    args = parser.parse_args()

    import ipdb;ipdb.set_trace()
    base = Path(__file__ + "/../" + args.version).resolve()
    if base.is_dir():
        rmtree(base)
    base.mkdir(exist_ok=True)

    multipy = parse_version(args.version) < parse_version("3.3")

    if multipy:
        py2 = base / "py2"
        py3 = base / "py3"
        py2.mkdir()
        unpack = py2
    else:
        unpack = base

    archive = f"v{args.version}.tar.gz"
    url = f"https://github.com/OSGeo/gdal/archive/{archive}"
    local = Path(f"/tmp/{archive}")

    if not local.exists():
        try:
            wget(url, "-O", str(local))
        except Exception:
            raise RuntimeError(f"Error downloading GDAL archive: {url}")

    try:
        tar(
            "xzf", str(local),
            "--strip-components=4", "-C", str(unpack),
            f"gdal-{args.version}/gdal/swig/python"
        )
    except Exception:
        tar(
            "xzf", str(local),
            "--strip-components=3", "-C", str(unpack),
            f"gdal-{args.version}/swig/python"
        )
    
    copytree(unpack / "gdal-utils" / "osgeo_utils", unpack / "osgeo_utils", dirs_exist_ok=True)

    for d in ("samples", "scripts", "gdal-utils"):
        if (unpack / d).is_dir():
            rmtree(unpack / d)
    find(str(unpack), "-maxdepth", "1", "-type", "f", "-delete")

    if multipy:
        copytree(unpack / "extensions", base / "extensions")
        rmtree(unpack / "extensions")
        copytree(unpack, py3)
        python(
            "-m", "lib2to3", "-w", "-n",
            "-f", "import", "-f", "next",
            "-f", "renames", "-f", "unicode",
            "-f", "ws_comma", "-f", "xrange",
            str(py3))

    (base / 'GDAL_VERSION').write_text(args.version)
    for s in ("setup.py", "MANIFEST.in", "README.rst"):
        (base / s).symlink_to("../" + s)

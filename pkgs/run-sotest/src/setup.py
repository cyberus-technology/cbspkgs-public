from distutils.core import setup

setup(
    name="run-sotest",
    version="1.0.0",
    author="Markus Napierkowski",
    author_email="markus.napierkowski@cyberus-technology.de",
    url="https://sotest.io/",
    description="A utility to schedule sotest test jobs",
    packages=["run_sotest"],
    entry_points={"console_scripts": ["run_sotest = run_sotest.__main__:main"]},
)

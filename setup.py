from setuptools import setup

setup(
    description="A simple game of cat and mouse",
    entry_points={"console_scripts": ["lazycat = lazycat:main"]},
    install_requires=["pygame"],
    license="GPLv3+",
    name="lazycat",
    package_data={"lazycat": ["assets/*", "LICENCE-*"]},
    packages=["lazycat"],
    version="1.0",
)

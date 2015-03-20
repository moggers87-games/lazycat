from setuptools import setup

classify = [
    "Intended Audience :: End Users/Desktop",
    "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
    "Operating System :: MacOS :: MacOS X",
    "Operating System :: Microsoft :: Windows",
    "Operating System :: POSIX :: Linux",
    "Programming Language :: Python :: 2.7",
    "Programming Language :: Python :: 3.3",
    "Programming Language :: Python",
    "Topic :: Games/Entertainment :: Role-Playing",
    "Topic :: Games/Entertainment",
]

setup(
    classifiers=classify,
    description="A simple game of cat and mouse",
    download_url="https://github.com/moggers87/lazycat/releases",
    entry_points={"console_scripts": ["lazycat = lazycat:main"]},
    install_requires=["pygame"],
    license="GPLv3+",
    name="lazycat",
    package_data={"lazycat": ["assets/*", "LICENCE-*"]},
    packages=["lazycat"],
    url="https://github.com/moggers87/lazycat",
    version="3.11",
)

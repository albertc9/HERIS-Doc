project = 'HERIS Documentation'
copyright = '2026, IHEP'
author = 'Albert ZHANG'

release = '0.1'
version = '0.1.0'


extensions = [
    'sphinx.ext.duration',
    'sphinx.ext.intersphinx',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}


html_theme = 'sphinx_rtd_theme'

html_static_path = ['_static']


epub_show_urls = 'footnote'
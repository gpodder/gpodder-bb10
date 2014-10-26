from xml.dom import minidom

import sys
import os

if len(sys.argv) != 2 or not os.path.exists(sys.argv[1]):
    print >>sys.stderr, 'Usage: %s <bar-descriptor.xml>' % (sys.argv[0], )

bar_descriptor_xml = sys.argv[1]

doc = minidom.parse(open(bar_descriptor_xml))

def get_text_from_element(name):
    elements = doc.getElementsByTagName(name)
    assert len(elements) == 1
    element = elements[0]
    assert len(element.childNodes) == 1
    text = element.childNodes[0]
    return text.data

print '.'.join((get_text_from_element('versionNumber'), get_text_from_element('buildId')))

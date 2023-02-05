#!/usr/bin/env python
"""
The MIT License (MIT)

Copyright (c) 2015-2017 Dave Parsons

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

from __future__ import print_function
import os
import sys
import shutil
import tarfile
import zipfile
import time
import urllib

try:
    # For Python 3.0 and later
    # noinspection PyCompatibility
    from urllib.request import urlopen
    # noinspection PyCompatibility
    from html.parser import HTMLParser
    # noinspection PyCompatibility
    from urllib.request import urlretrieve
except ImportError:
    # Fall back to Python 2
    # noinspection PyCompatibility
    from urllib2 import urlopen
    # noinspection PyCompatibility
    from HTMLParser import HTMLParser


# Parse the Fusion directory page
class CDSParser(HTMLParser):

    def __init__(self):
        HTMLParser.__init__(self)
        self.reset()
        self.HTMLDATA = []

    def handle_data(self, data):
        # Build a list of numeric data from any element
        if data.find("\n") == -1:
            if data[0].isdigit():
                self.HTMLDATA.append(data)
                self.HTMLDATA.sort(key=lambda s: [int(u) for u in s.split('.')])

    def clean(self):
        self.HTMLDATA = []

if sys.version_info > (3, 0):
# Python 3 code in this block
	pass
else:
	# Python 2 code in this block
	class MyURLopener(urllib.FancyURLopener):
		http_error_default = urllib.URLopener.http_error_default

def convertpath(path):
    # OS path separator replacement function
    return path.replace(os.path.sep, '/')

def reporthook(count, block_size, total_size):
	global start_time
	if count == 0:
		start_time = time.time()
		return
	duration = time.time() - start_time
	progress_size = int(count * block_size)
	speed = int(progress_size / (1024 * duration)) if duration>0 else 0
	percent = min(int(count*block_size*100/total_size),100)
	time_remaining = ((total_size - progress_size)/1024) / speed if speed > 0 else 0
	sys.stdout.write("\r...%d%%, %d MB, %d KB/s, %d seconds remaining   " %
					(percent, progress_size / (1024 * 1024), speed, time_remaining))
	sys.stdout.flush()

def CheckToolsFilesExists(dest):
	filesFound = os.path.exists(convertpath(dest + '/tools/darwin.iso')) & os.path.exists(convertpath(dest + '/tools/darwinPre15.iso'))
	askMsg = 'You already have downloaded the tools. Download again?[y/n]'

	if filesFound:
		while True:
			# Ask if the user want to download again
			if sys.version_info > (3, 0):
			# Python 3 code in this block
				userResponse = input(askMsg)
			else:
				# Python 2 code in this block
				userResponse = raw_input(askMsg)
			
			if str(userResponse).upper() == 'Y':
				return False
			elif str(userResponse).upper() == 'N':
				return True
			else:
				print('Must enter y or n. You pressed: ' + str(userResponse).upper())
	else:
		return False

def main():
	# Check minimal Python version is 2.7
	if sys.version_info < (2, 7):
		sys.stderr.write('You need Python 2.7 or later\n')
		sys.exit(1)

	dest = os.getcwd()

	# Try local file check
	if(CheckToolsFilesExists(dest)):
		# User as already download the tools and chosen not doing again
		return

	# Re-create the tools folder
	shutil.rmtree(dest + '/tools', True)
	try:
		os.mkdir(dest + '/tools')
	except :
		pass

	parser = CDSParser()

	# Last published version doesn't ship with darwin tools
	# so in case of error get it from the core.vmware.fusion.tar
	print('Trying to get tools from the packages folder...')

	# Setup secure url and file paths
	url = 'https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/'

	# Get the list of Fusion releases
	# And get the last item in the ul/li tags
	
	response = urlopen(url)
	html = response.read()
	parser.clean()
	parser.feed(str(html))
	url = url + parser.HTMLDATA[-1] + '/'
	parser.clean()

	# Open the latest release page
	# And build file URL
	response = urlopen(url)
	html = response.read()
	parser.feed(str(html))
	
	lastVersion = parser.HTMLDATA[-1]
	
	urlpost15 = url + lastVersion + '/packages/com.vmware.fusion.tools.darwin.zip.tar'
	urlpre15 = url + lastVersion + '/packages/com.vmware.fusion.tools.darwinPre15.zip.tar'
	parser.clean()

	# Download the darwin.iso tgz file
	print('Retrieving Darwin tools from: ' + urlpost15)
	try:
		# Try to get tools from packages folder
		if sys.version_info > (3, 0):
			# Python 3 code in this block
			urlretrieve(urlpost15, convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip.tar'), reporthook)
		else:
			# Python 2 code in this block
			(f,headers)=MyURLopener().retrieve(urlpost15, convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip.tar'), reporthook)
	except:
		# No tools found, get them from the core tar
		print('Tools aren\'t here... Be patient while I download and' +
			  ' give a look into the core.vmware.fusion.tar file')
		urlcoretar = url + lastVersion + '/core/com.vmware.fusion.zip.tar'
		print('Retrieving Darwin tools from: ' + urlcoretar)	

		# Get the main core file
		try:
			if sys.version_info > (3, 0):
				# Python 3 code in this block
				urlretrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
			else:
				# Python 2 code in this block
				(f,headers)=MyURLopener().retrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
		except:
			# No tools found, get them from the x86 core tar
			print('Tools aren\'t here... Be patient while I download and' +
				' give a look into the x86.core.vmware.fusion.tar file')
			urlcoretar = url + lastVersion + '/x86/core/com.vmware.fusion.zip.tar'
			print('Retrieving Darwin tools from: ' + urlcoretar)	

			# Get the main core file
			try:
				if sys.version_info > (3, 0):
					# Python 3 code in this block
					urlretrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
				else:
					# Python 2 code in this block
					(f,headers)=MyURLopener().retrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
			except:
				# print('Couldn\'t find tools')
				# return
							# No tools found, get them from the x86 core tar
				print('Tools aren\'t here... Be patient while I download and' +
					' give a look into the com.vmware.fusion.zip.tar file')
				urlcoretar = url + lastVersion + '/universal/core/com.vmware.fusion.zip.tar'
				print('Retrieving Darwin tools from: ' + urlcoretar)	

				# Get the main core file
				try:
					if sys.version_info > (3, 0):
						# Python 3 code in this block
						urlretrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
					else:
						# Python 2 code in this block
						(f,headers)=MyURLopener().retrieve(urlcoretar, convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), reporthook)
				except:
					print('Couldn\'t find tools')
					return
			
		print()
		
		print('Extracting com.vmware.fusion.zip.tar...')
		tar = tarfile.open(convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), 'r')
		tar.extract('com.vmware.fusion.zip', path=convertpath(dest + '/tools/'))
		tar.close()
		
		print('Extracting files from com.vmware.fusion.zip...')
		cdszip = zipfile.ZipFile(convertpath(dest + '/tools/com.vmware.fusion.zip'), 'r')

		isoPath = ''
		if 'payload/VMware Fusion.app/Contents/Library/isoimages/x86_x64/' in cdszip.namelist():
			isoPath = 'payload/VMware Fusion.app/Contents/Library/isoimages/x86_x64/'
		else:
			isoPath = 'payload/VMware Fusion.app/Contents/Library/isoimages/'

		cdszip.extract(isoPath + 'darwin.iso', path=convertpath(dest + '/tools/'))
		cdszip.extract(isoPath + 'darwinPre15.iso', path=convertpath(dest + '/tools/'))
		cdszip.close()
		
		# Move the iso and sig files to tools folder
		shutil.move(convertpath(dest + '/tools/' + isoPath + 'darwin.iso'), convertpath(dest + '/tools/darwin.iso'))
		shutil.move(convertpath(dest + '/tools/' + isoPath + 'darwinPre15.iso'), convertpath(dest + '/tools/darwinPre15.iso'))
		
		# Cleanup working files and folders
		shutil.rmtree(convertpath(dest + '/tools/payload'), True)
		os.remove(convertpath(dest + '/tools/com.vmware.fusion.zip.tar'))
		os.remove(convertpath(dest + '/tools/com.vmware.fusion.zip'))
		
		print('Tools from core retrieved successfully')
		return

	# Tools have been found in the packages folder, go with the normal way
	
	# Extract the tar to zip
	tar = tarfile.open(convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip.tar'), 'r')
	tar.extract('com.vmware.fusion.tools.darwin.zip', path=convertpath(dest + '/tools/'))
	tar.close()

	# Extract the iso and sig files from zip
	cdszip = zipfile.ZipFile(convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip'), 'r')
	cdszip.extract('payload/darwin.iso', path=convertpath(dest + '/tools/'))
	cdszip.extract('payload/darwin.iso.sig', path=convertpath(dest + '/tools/'))
	cdszip.close()

	# Move the iso and sig files to tools folder
	shutil.move(convertpath(dest + '/tools/payload/darwin.iso'), convertpath(dest + '/tools/darwin.iso'))
	shutil.move(convertpath(dest + '/tools/payload/darwin.iso.sig'), convertpath(dest + '/tools/darwin.iso.sig'))

	# Cleanup working files and folders
	shutil.rmtree(convertpath(dest + '/tools/payload'), True)
	os.remove(convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip.tar'))
	os.remove(convertpath(dest + '/tools/com.vmware.fusion.tools.darwin.zip'))

	# Download the darwinPre15.iso tgz file
	print('Retrieving DarwinPre15 tools from: ' + urlpre15)
	urlretrieve(urlpre15, convertpath(dest + '/tools/com.vmware.fusion.tools.darwinPre15.zip.tar'))

	# Extract the tar to zip
	tar = tarfile.open(convertpath(dest + '/tools/com.vmware.fusion.tools.darwinPre15.zip.tar'), 'r')
	tar.extract('com.vmware.fusion.tools.darwinPre15.zip', path=convertpath(dest + '/tools/'))
	tar.close()

	# Extract the iso and sig files from zip
	cdszip = zipfile.ZipFile(convertpath(dest + '/tools/com.vmware.fusion.tools.darwinPre15.zip'), 'r')
	cdszip.extract('payload/darwinPre15.iso', path=convertpath(dest + '/tools/'))
	cdszip.extract('payload/darwinPre15.iso.sig', path=convertpath(dest + '/tools/'))
	cdszip.close()

	# Move the iso and sig files to tools folder
	shutil.move(convertpath(dest + '/tools/payload/darwinPre15.iso'),
				convertpath(dest + '/tools/darwinPre15.iso'))
	shutil.move(convertpath(dest + '/tools/payload/darwinPre15.iso.sig'),
				convertpath(dest + '/tools/darwinPre15.iso.sig'))

	# Cleanup working files and folders
	shutil.rmtree(convertpath(dest + '/tools/payload'), True)
	os.remove(convertpath(dest + '/tools/com.vmware.fusion.tools.darwinPre15.zip.tar'))
	os.remove(convertpath(dest + '/tools/com.vmware.fusion.tools.darwinPre15.zip'))

	print('Tools from package retrieved successfully')

if __name__ == '__main__':
    main()

.PHONY: build-info resources

help:
	@echo "Valid options are: macosx"

all: clean macosx

clean:
	@rm -rf build dist
	
build-info:
	@git describe --dirty --always > build-info
	
deps: build-info

macosx: ce-macosx sf-macosx
	mkdir dist/macosx/SpaceFortress\ 5.0
	mkdir dist/macosx/bundle
	mv dist/macosx/*.app dist/macosx/SpaceFortress\ 5.0/
	python mac-tools/AssignIcon.py psf5.png dist/macosx/SpaceFortress\ 5.0
	mv dist/macosx/SpaceFortress\ 5.0 dist/macosx/bundle
	sh mac-tools/create-dmg --window-pos 400 400 --window-size 384 224 --volname SpaceFortress dist/macosx/SpaceFortress.dmg dist/macosx/bundle
	rm -rf dist/macosx/bundle

sf-macosx: deps
	rm -rf dist/macosx/SpaceFortress*
	arch -i386 python setup-sf.py build
	mkdir -p dist/macosx/SpaceFortress.app/Contents
	mkdir dist/macosx/SpaceFortress.app/Contents/MacOS
	cp build-info dist/macosx/SpaceFortress.app/Contents/MacOS
	cp psf5.png dist/macosx/SpaceFortress.app/Contents/MacOS
	mkdir dist/macosx/SpaceFortress.app/Contents/Resources
	cp psf5.icns dist/macosx/SpaceFortress.app/Contents/Resources
	cp Info.plist.sf dist/macosx/SpaceFortress.app/Contents/Info.plist
	echo "APPL????" > dist/macosx/SpaceFortress.app/Contents/PkgInfo
	mv build/exe.macosx-10.6-*-2.7/PSF5 dist/macosx/SpaceFortress.app/Contents/MacOS/SpaceFortress
	mv build/exe.macosx-10.6-*-2.7/PSF5.zip dist/macosx/SpaceFortress.app/Contents/MacOS/SpaceFortress.zip
	mv build/exe.macosx-10.6-*-2.7/*.dylib dist/macosx/SpaceFortress.app/Contents/MacOS/
	mv build/exe.macosx-10.6-*-2.7/*.so dist/macosx/SpaceFortress.app/Contents/MacOS/
	mv build/exe.macosx-10.6-*-2.7/*.zip dist/macosx/SpaceFortress.app/Contents/MacOS/
	morelibs=`ls build/exe.macosx-10.6-*-2.7`
	cd dist/macosx/SpaceFortress.app/Contents/MacOS; \
	for f in `ls *.so`; do \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done; \
	for f in `ls *.dylib`; do \
		install_name_tool -id @executable_path/$$f $$f; \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done
	mv build/exe.macosx-10.6-*-2.7/* dist/macosx/SpaceFortress.app/Contents/MacOS/
	cd dist/macosx/SpaceFortress.app/Contents/MacOS; \
	install_name_tool -id @executable_path/Python Python; \
	for f in $$morelibs; do \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done
	mv dist/macosx/SpaceFortress.app dist/macosx/SpaceFortress-fat.app
	ditto --rsrc --arch i386 dist/macosx/SpaceFortress-fat.app dist/macosx/SpaceFortress.app
	rm -rf dist/macosx/SpaceFortress-fat.app
	/Developer/Tools/SetFile -a B dist/macosx/SpaceFortress.app

ce-macosx:
	rm -rf dist/macosx/configEditor*
	arch -i386 python setup-ce.py build
	mkdir -p dist/macosx/configEditor.app/Contents
	mkdir dist/macosx/configEditor.app/Contents/MacOS
	mkdir dist/macosx/configEditor.app/Contents/Resources
	cp prefs.icns dist/macosx/configEditor.app/Contents/Resources
	cp Info.plist.ce dist/macosx/configEditor.app/Contents/Info.plist
	echo "APPL????" > dist/macosx/configEditor.app/Contents/PkgInfo
	mv build/exe.macosx-10.6-*-2.7/configEditor dist/macosx/configEditor.app/Contents/MacOS/
	mv build/exe.macosx-10.6-*-2.7/*.dylib dist/macosx/configEditor.app/Contents/MacOS/
	mv build/exe.macosx-10.6-*-2.7/PySide* dist/macosx/configEditor.app/Contents/MacOS/
	mv build/exe.macosx-10.6-*-2.7/*.zip dist/macosx/configEditor.app/Contents/MacOS/
	morelibs=`ls build/exe.macosx-10.6-*-2.7`
	/opt/local/bin/macdeployqt dist/macosx/configEditor.app
	cd dist/macosx/configEditor.app/Contents/Frameworks; \
	rm -rf QtDeclarative.framework; \
	rm -rf QtNetwork.framework; \
	rm -rf QtScript.framework; \
	rm -rf QtSql.framework; \
	rm -rf QtSvg.framework; \
	rm -rf QtXmlPatterns.framework
	cd dist/macosx/configEditor.app/Contents/MacOS; \
	rm libQtCore.4.dylib; \
	rm libQtGui.4.dylib; \
	install_name_tool -change /opt/local/lib/libQtCore.4.dylib @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore PySide.QtCore.so; \
	install_name_tool -change /opt/local/lib/libQtGui.4.dylib @executable_path/../Frameworks/QtGui.framework/Versions/4/QtGui PySide.QtGui.so; \
	install_name_tool -change /opt/local/lib/libQtCore.4.dylib @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore PySide.QtGui.so; \
	install_name_tool -change /opt/local/lib/libQtCore.4.dylib @executable_path/../Frameworks/QtCore.framework/Versions/4/QtCore libpyside-python2.7.1.0.dylib; \
	for f in `ls *.so`; do \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done; \
	for f in `ls *.dylib`; do \
		install_name_tool -id @executable_path/$$f $$f; \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done
	mv build/exe.macosx-10.6-*-2.7/* dist/macosx/configEditor.app/Contents/MacOS/
	cd dist/macosx/configEditor.app/Contents/MacOS; \
	install_name_tool -id @executable_path/Python Python; \
	install_name_tool -change /opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python @executable_path/Python configEditor; \
	for f in $$morelibs; do \
		libs=`otool -XL $$f | grep "/opt/local/lib" | cut -f 2 | cut -f 1 -d " "`; \
 		if [[ -n $$libs ]]; then \
  			for l in $$libs; do \
   				ll=`echo $$l | cut -f 5 -d"/"`; \
   				install_name_tool -change $$l @executable_path/$$ll $$f; \
  			done; \
 		fi; \
	done
	mv dist/macosx/configEditor.app dist/macosx/configEditor-fat.app
	ditto --rsrc --arch i386 dist/macosx/configEditor-fat.app dist/macosx/configEditor.app
	rm -rf dist/macosx/configEditor-fat.app
	/Developer/Tools/SetFile -a B dist/macosx/configEditor.app

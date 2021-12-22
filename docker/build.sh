#!/bin/bash

VERSION=$(git describe --abbrev=0)
echo "Version is $VERSION"

if head -n1 ../debian/changelog | grep $VERSION ; then
   echo "Latest version. I should not do a thing"
else
   echo "It's not the latest version. Adding a new tag to changelog"

### Adding a new changelog entry. Yes, I use ex

   ex ../debian/changelog << EOM
1 insert
lmod ($VERSION) unstable; urgency=medium

  * Setting TAG_VERSION to $VERSION

 -- Alexandre Strube <surak@surak.eti.br>  $(date)


.
xit
EOM

### Adding the filenames to debian/files with correct version

   cat > ../debian/files << EOM
lmod_${VERSION}_all.deb devel optional
lmod_${VERSION}_amd64.buildinfo devel optional
EOM

### Adding right version to dockerfile
sed "s/git checkout tags.*/git checkout tags\/$VERSION \; \\ /g" Dockerfile
sed "s/lmod_.*/lmod_${VERSION}_all.deb/g" Dockerfile 
### 
git add ../debian/files ../debian/changelog Dockerfile
git commit -m "Added tag ${VERSION}" 
git push
docker build .

fi

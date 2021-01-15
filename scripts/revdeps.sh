#!/usr/bin/env bash

PKGDB_DIR=/var/lib/pkg/DB

SEARCH_DIRS="/bin /usr/bin /sbin /usr/sbin /lib /usr/lib /lib64 /usr/lib64 /usr/libexec"

FILE_LIST="/tmp/.revdep.$$"

printf "Find all files... "
find ${SEARCH_DIRS} -type f \( -perm /+u+x -o -name '*.so' -o -name '*.so.*' \) -print 2> /dev/null | sort -u > $FILE_LIST

cat $FILE_LIST

total=$(cat ${FILE_LIST} | wc -l)
count=0
echo "$total files found"

echo "Checking for broken linkage..."
while read -r line; do
	count=$(( count + 1 ))
	libname=$(basename "$line")
	printf " $(( 100*count/total ))%% $libname\033[0K\r"
	case "$(file -bi "$line")" in
		*application/x-sharedlib* | *application/x-executable* | *application/x-pie-executable*)
			if ldd $line 2>/dev/null | grep -q "not found"; then
				LIB_NAME=$(ldd $line 2>/dev/null | grep "not found" | sort | uniq | awk '{print $1}')
				for l in $LIB_NAME; do
					NEW_LIB_NAME="$NEW_LIB_NAME $l"
				done
				LIB_NAME=$NEW_LIB_NAME
				[ "$LIB_NAME" ] || continue
				PKG_NAME=$(echo $line | sed 's#^/##')
				PKG_NAME=$(grep -Rx $PKG_NAME "$PKGDB_DIR"/*/files | cut -d : -f1)
				[ "$PKG_NAME" ] || continue
				PKG_NAME=$(dirname $PKG_NAME)
				PKG_NAME=$(basename $PKG_NAME)
				echo $expkg | tr ' ' '\n' | grep -qx $PKG_NAME && continue
				REQ_LIB=$(objdump -p $line 2>/dev/null | grep NEEDED | awk '{print $2}' | tr '\n' ' ')
				for i in $LIB_NAME; do
					[ "$PRINTALL" = 1 ] && echo " $PKG_NAME -> $line (requires $i)"
					if echo $REQ_LIB | tr ' ' '\n' | grep -qx $i; then
						[ "$PRINTALL" = 1 ] || echo " $PKG_NAME -> $line (requires $i)"
						if echo "$ALLPKG" | tr ' ' '\n' | grep -qx "$PKG_NAME"; then
							continue
						else
							ALLPKG="$ALLPKG $PKG_NAME"
						fi
					fi
				done
			fi
			;;
	esac
	unset NEW_LIB_NAME
done < $FILE_LIST

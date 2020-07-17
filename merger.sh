#!/bin/bash
# usage: merger.sh fromBranchName toBranchName tagName

fromBranch=$1
toBranch=$2
tagName=$3

# validate
if [ -z "$fromBranch" ]; then
    echo "[merger.sh] fromBranch is required: usage: merger.sh fromBranchName toBranchName tagName"
    exit 1
fi
if [ -z "$toBranch" ]; then
    echo "[merger.sh] toBranch is required: usage: merger.sh fromBranchName toBranchName tagName"
    exit 1
fi
if [ -z "$tagName" ]; then
    echo "[merger.sh] tagName is required: usage: merger.sh fromBranchName toBranchName tagName"
    exit 1
fi

# legit project?
git status
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] git status returned non-zero exit code: $exitCode. We are not in a git project?"
    exit 1
fi

# setup our tag modifier
tsUtc=$(date -u +%Y%m%d_%H%M%SZ)
tagName="$tsUtc-$tagName"


# checkout fromBrach
git checkout $fromBranch
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git checkout $fromBranch' failed with exit-code $exitCode"
    exit $exitCode
fi
git fetch origin


# checkout toBranch
git checkout $toBranch
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git checkout $toBranch' failed with exit-code $exitCode"
    exit $exitCode
fi
git fetch origin

# get current branch
currBranch=$(git branch | grep \* | tr -cd '[:alnum:]')
echo "[merger.sh] Current branch = $currBranch"

# ensure we are where we need to be (in the target $toBranch)
if [ "$currBranch" != "$toBranch" ]; then
    echo "[merger.sh] currBranch[$currBranch] != toBranch[$toBranch], executing 'git checkout $toBranch'...."
    git checkout $toBranch
    git fetch origin
    
    exitCode=$?
    if [ "$exitCode" != 0 ]; then
        echo "[merger.sh] 'git checkout $toBranch' failed with exit-code $exitCode"
        exit $exitCode
    fi

    currBranch=$(git branch | grep \* | tr -cd '[:alnum:]')
    echo "[merger.sh] post-checkout: current branch now = $currBranch"
fi

# sanity
if [ "$currBranch" != "$toBranch" ]; then
    echo "[merger.sh] 'git checkout $toBranch' failed? currBranch[$currBranch] != toBranch[$toBranch]... exiting"
    exit 1
fi

# ok lets merge
git merge $fromBranch
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git merge $fromBranch' from within $currBranch, failed with exit-code $exitCode"
    exit $exitCode
fi

echo "[merger.sh] 'git merge $fromBranch' from within $currBranch successful"


# ok lets push 
git push
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git push' from within $currBranch failed with exit-code $exitCode"
    exit $exitCode
fi

echo "[merger.sh] 'git push' from within $currBranch successful"

# ok lets tag
git tag -a $tagName -m "merger.sh $fromBrach -> $toBranch at $tsUtc: tag=$tagName"
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git tag -a $tagName'  from within $currBranch failed with exit-code $exitCode"
    exit $exitCode
fi

echo "[merger.sh] 'git tag -a $tagName' from within $currBranch successful"

# and lets push
git push origin $tagName 
exitCode=$?
if [ "$exitCode" != 0 ]; then
    echo "[merger.sh] 'git push origin $tagName' from within $currBranch failed with exit-code $exitCode"
    exit $exitCode
fi

echo "[merger.sh] 'git push origin $tagName' from within $currBranch successful"

exit 0
# merger.sh

Simple utility for merging branches w/ auto-tagging 

## Usage

```
merger.sh fromBranchName toBranchName tagName
```


## Example

Clone this repo:
```
git clone https://github.com/bitsofinfo/merger.sh
```

Fork the test repo: https://github.com/bitsofinfo/merge-test-1

Clone your FORK above https://github.com/[your account]/merge-test-1
```
git clone https://github.com/[your account]/merge-test-1
cd merge-test-1
```

Progress a change through the branches
```
git checkout develop

echo "new file" > new-file.txt
git add new-file.txt
git commit new-file.txt -m "new-file.txt"
git push
```

Lets merge to `qa`, then `master` with auto tagging markers
```
merger.sh develop qa qa-NewFileChange
merger.sh qa master master-NewFileChange
```




# Copyright (c) 2016 foresterre
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# script input argument: directory
# purpose: Returns the sha256 hashes of all files, one directory deep,
#          at the specified directory.
#          For each file, a combination, 'hash file_name' is stored in a
#          file called 'hashes.sha256'
#
# todo: compat. with recursive directories and files
#       pointers (e.g.): Set-Location,
#                        one output file per directory:
#                           <root>/root1.bin
#                           <root>/<subdir>/sub1.bin
#
#                        will become:
#                           <root>/hashes.sha256 -> containing a hash for root1.bin
#                           <root>/root1.bin
#                           <root>/<subdir>/hashes.sha256 -> containing a hash for sub1.bin
#                           <root>/<subdir>/sub1.bin
#

$dirArgument = $args[0]

# verify input information
if ($dirArgument -eq $null) {
    Write-Host "Error, no argument provided!"
    Exit
}

$dirTestPath = Test-Path $dirArgument
if (-Not $dirTestPath) {
    Write-Host "Error, path not found!"
    Exit
}

# config
$outputFileName = "hashes.sha256"
$outputFilePath = Join-Path -Path $dirArgument -ChildPath $outputFileName

# clean output
$outputFileExist = Test-Path $outputFilePath
if ($outputFileExist) {
    Clear-Content $outputFilePath
}

# process input
$dirFiles = Get-ChildItem $dirArgument -File -Exclude *.sha256

$dirFiles | Foreach-Object {
    $fPath = $_.FullName
    $hash = Get-FileHash $fPath -Algorithm SHA256

    $hashFmt = $hash.Hash
    $fNameFmt = $_.Name #Resolve-Path -Relative $fPath
    $resultFmt =  "$hashFmt $fNameFmt"

    $resultFmt | Out-File $outputFilePath -Append
}
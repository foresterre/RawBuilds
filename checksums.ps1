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
#          file called 'checksums.sha256'


$dirArgument = $args[0]
$requiredArgumentStr = "The first argument should be an existing directory. Usage: ./checksums [directory]"

# verify input information
if ($dirArgument -eq $null) {
    Write-Host "Error, no argument provided!"
    Write-Host $requiredArgumentStr
    Exit
}

$dirTestPath = Test-Path $dirArgument
if (-Not $dirTestPath) {
    Write-Host "Error, path not found!"
    Write-Host $requiredArgumentStr
    Exit
}


# config
$outputFileName = "checksums.sha256"
$outputFilePath = Join-Path -Path $dirArgument -ChildPath $outputFileName


# clean output
$outputFileExist = Test-Path $outputFilePath
if ($outputFileExist) {
    Write-Host "Output file 'checksum.sha256' does already exist, cleaning file..."
    Clear-Content $outputFilePath
} else {
    Write-Host "Created output file: 'checksums.sha256\'".
    Out-File $outputFileName
}


# process input
$dirFiles = Get-ChildItem $dirArgument -File | Where-Object { $_.Name -ne "checksums.sha256" }

$dirFiles | ForEach-Object {
    $fPath = $_.FullName
    $hash = Get-FileHash $fPath -Algorithm SHA256

    $hashFmt = $hash.Hash
    $fNameFmt = $_.Name #Resolve-Path -Relative $fPath
    $resultFmt =  "$hashFmt $fNameFmt"

    Write-Host "Appending hash: ", $resultFmt

    $resultFmt | Out-File $outputFilePath -Append
}
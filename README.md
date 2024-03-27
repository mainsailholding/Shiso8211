[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![X](https://img.shields.io/badge/X-@JoeCharlier-blue.svg?style=flat)](http://twitter.com/JoeCharlier)
# Shiso8211

A Swift based ISO-8211 file reader for use with IHO-S57 chart files.

![Shiso](Shiso256.png)
### Swift Package Manager

Add the following to the ```dependencies``` section of the Package.swift file:
```swift
.package(url: "https://github.com/aepryus/Shiso8211.git", branch: "master"),
```

Or from Xcode go to `File/Add Packages` and enter the URL: `https://github.com/aepryus/Shiso8211.git`.

### About

The ISO8211 spec was intended to be a generalized binary file spec, but in reality it seems to have largely been used only for the IHO S57.  (ISO8211 is being dropped in favor of XML for S-100 and beyond.)

This implementation signficantly referenced Frank Warmerdam's C++ library and got its start from [Chris Alford's](https://github.com/chrisvalford) Swift based [ISO8211](https://github.com/chrisvalford/ISO8211).  As such this is not a generalized ISO8211 reader but rather has been tuned only on IHO S57 files.

The initial ISO8211 spec was published in 1985; the latest version was published in 1994; Warmerham's implementation dates from 1999 - a time when computers were much less capable.  With the capability of computers these days and the size of S57 files being not terribly big this library does not bother with streaming the files; it simply loads them into native ISO8211 objects.

This is done as such:

```swift
    guard let module: ISOModule = ISOModule(path: path) else { return }
    for record: ISORecord in module.records {
        for field: ISOField in record.fields {
            for row: ISORow = field.rows {
                for value: ISOValue in row.values {
```

Once instantiated the ISOModule object will have the full file loaded and the ISOFieldDef, ISOSubfieldDef, ISORecord, ISOField, ISORow and ISOValue objects can be traversed as expected.

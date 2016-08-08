/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  StorageStream.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/2/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "StorageStreamParser.h"
#import "Header.h"
#import "StreamHandle.h"
#import "StreamReader.h"
#import "Sector.h"
#import "DirectoryEntry.h"
#import "CFileReaderError.h"
#import "Stream.h"

@interface StorageStreamParser ()
{
    NSInteger n_sector;
}

@property (nonatomic, strong) Header *header;
@property (nonatomic, strong) NSMapTable *sectorCollection;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, strong) NSPointerArray *directoryEntries;
@property (nonatomic, strong) NSInputStream *fileInputStream;

@end

@implementation StorageStreamParser
{
    NSInteger _childSID;
}

- (void)dealloc
{
    [_fileInputStream close];
    _fileInputStream = nil;
    _directoryEntries = nil;
    _sectorCollection = nil;
    _rootStorage = nil;
}

+ (StorageStreamParser *)sharedInstance
{
    static dispatch_once_t onceToken;
    static StorageStreamParser *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StorageStreamParser alloc] init];
    });
    
    return sharedInstance;
}

- (void)setFilePath:(NSString *)filePath
{
    _fileInputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    _fileSize = [fileAttributes[NSFileSize] integerValue];
    FILESIZE = (int)_fileSize;
    [_fileInputStream open];
    _directoryEntries = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality];
}

#pragma mark - Start

- (BOOL)readFile:(NSError *__autoreleasing*)error
{
    if (![self isValidHeader:error]) {
        return NO;
    }
    
    [self populateDirectories];
    
    [self loadRedBlackBinaryTreeFromDirectories];
    
    return YES;
}

- (BOOL)isValidHeader:(NSError *__autoreleasing*)error
{
    _header = [[Header alloc] init];
    
    if ([self.header readHeaderAndValidate:self.fileInputStream error:error]) {
        return YES;
    }
    return NO;
}

- (void)populateDirectories
{
    //Obtain total number of sectors...
    n_sector = ceil(((double)(self.fileSize - [self getSectorSize]) / (double)[self getSectorSize]));
    
    _sectorCollection = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory capacity:n_sector];
    
    //Obtain the directory sectors..
    NSArray *sectors = [self getSectorChainFirstDirectorySectorID:self.header.firstDirectorySectorID sectorType:SectorTypeNormal];
    
    StreamHandle *dirReader = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:sectors sectorSize:[self getSectorSize] length:(sectors.count * [self getSectorSize])];
    
    //Populate each Directory Entry from sectors...
    while (dirReader.sectorPosition < (sectors.count * [self getSectorSize])) {
        DirectoryEntry *directoryEntry = [[DirectoryEntry alloc] initWithNodeType:NodeTypeInvalid];
        [directoryEntry populateData:dirReader];
        directoryEntry.sIdentifier = self.directoryEntries.count;
        [self.directoryEntries addPointer:(__bridge void *)(directoryEntry)];
    }
}

- (NSData *)loadDataOfDirectoryEntryID:(NSInteger)sIdentifier
{
    DirectoryEntry *directoryEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:sIdentifier];
    
    StreamHandle *streamHandle = nil;
    
    if (directoryEntry.sizeOfEntry < self.header.minSizeStandardStream) {
        streamHandle = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:[self getSectorChainFirstDirectorySectorID:directoryEntry.startSectC sectorType:SectorTypeMini] sectorSize:MINISECTOR_SIZE length:directoryEntry.sizeOfEntry];
    } else {
        streamHandle = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:[self getSectorChainFirstDirectorySectorID:directoryEntry.startSectC sectorType:SectorTypeNormal] sectorSize:[self getSectorSize] length:directoryEntry.sizeOfEntry];
    }
    
    NSMutableData *buffer = [[NSMutableData alloc] initWithLength:directoryEntry.sizeOfEntry];
    [streamHandle read:(uint8_t *)buffer.mutableBytes maxLength:directoryEntry.sizeOfEntry];
    return buffer;
}

#pragma mark - Sectors

- (NSArray *)getSectorChainFirstDirectorySectorID:(NSInteger)secID sectorType:(SectorType)sectorType
{
    NSArray *streamAndSectorArray = nil;
    switch (sectorType) {
        case SectorTypeDIFAT:
            streamAndSectorArray = [self getDIFATSectorChain];
            break;
        case SectorTypeFAT:
            streamAndSectorArray = [self getFATSectorChain];
            break;
        case SectorTypeNormal:
            streamAndSectorArray = [self getNormalSectorChain:(int)secID];
            break;
        case SectorTypeMini:
            streamAndSectorArray = [self getMiniSectorChain:(int)secID];
            break;
        default:
            streamAndSectorArray = nil;
            break;
    }
    return streamAndSectorArray;
}

- (NSArray *)getDIFATSectorChain
{
    int validationCount = 0;
    
    NSMutableArray *difatSectorChain = [[NSMutableArray alloc] init];
    int nextSecID = ENDOFCHAIN;
    
    if (self.header.DIFATSectorsNumber != 0) {
        
        validationCount = (int)self.header.DIFATSectorsNumber;
        
        Sector *sector = nil;
        if([self.sectorCollection objectForKey:[@(self.header.firstDIFATSectorID) stringValue]]){
            sector = [self.sectorCollection objectForKey:[@(self.header.firstDIFATSectorID) stringValue]];
        } else {
            sector = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:[self getSectorSize]];
            sector.sectorType = SectorTypeDIFAT;
            sector.identifier = self.header.firstDIFATSectorID;
            [self.sectorCollection setObject:sector forKey:[@(self.header.firstDIFATSectorID) stringValue]];
        }
        
        [difatSectorChain addObject:sector];
        
        while (validationCount > 0) {
            
            Byte *present = (Byte *)malloc(4 * sizeof(Byte));
            NSData* tempData = [sector getData];
            //http://download.microsoft.com/download/9/5/E/95EF66AF-9026-4BB0-A41D-A4F81802D92C/[MS-CFB].pdf
            //Refer page number 21. Files of < 6.8MB does not have DIFAT sector(So this is not executed). For file above this size, the last 4 bytes of 512 bytes has the next Sec ID.
            
            if (present) {
                NSData *data4 = [tempData subdataWithRange:NSMakeRange(508, 4)];
                int value;
                [data4 getBytes:&value length:sizeof(value)]; //todo_irm Temporary change.
                //                [data4 getBytes:present length:4];
                //              //  present = data4;
                //                  value = CFSwapInt32BigToHost(*(int*)([data4 bytes]));
                //                int temp = [self getIntFromBytes:present];
                nextSecID = value;//[self getIntFromBytes:present];
                
                if (nextSecID == FREESECT || nextSecID == ENDOFCHAIN) {
                    free(present);
                    break;
                }
                
                validationCount--;
                
                if (validationCount < 0) {
                    free(present);
                    return nil;
                }
                
                sector = nil;
                if([self.sectorCollection objectForKey:[@(nextSecID) stringValue]]){
                    sector = [self.sectorCollection objectForKey:[@(nextSecID) stringValue]];
                } else {
                    sector = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:[self getSectorSize]];
                    sector.sectorType = SectorTypeDIFAT;
                    sector.identifier = nextSecID;
                    [self.sectorCollection setObject:sector forKey:[@(nextSecID) stringValue]];
                }
                
                [difatSectorChain addObject:sector];
            }
            free(present);
        }
    }
    return difatSectorChain;
}

- (NSArray *)getFATSectorChain
{
    int N_HEADER_FAT_ENTRY = 109; //Number of FAT sectors id in the header
    
    NSMutableArray *FATSectorChain = [[NSMutableArray alloc] init];
    
    int nextSecID = ENDOFCHAIN;
    
    NSArray *difatSectors = [self getDIFATSectorChain];
    
    int idx = 0;
    
    // Read FAT entries from the header Fat entry array (max 109 entries)
    while (idx < self.header.FATSectorsNumber && idx < N_HEADER_FAT_ENTRY)
    {
        nextSecID = (int)self.header.DIFAT[idx];
        Sector *sector = nil;
        if([self.sectorCollection objectForKey:[@(nextSecID) stringValue]]){
            sector = [self.sectorCollection objectForKey:[@(nextSecID) stringValue]];
        } else {
            sector = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:[self getSectorSize]];
            sector.sectorType = SectorTypeDIFAT;
            sector.identifier = nextSecID;
            [self.sectorCollection setObject:sector forKey:[@(nextSecID) stringValue]];
        }
        
        [FATSectorChain addObject:sector];
        
        idx++;
    }
    
    if (difatSectors.count > 0)
    {
        StreamHandle *difatStream
        = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:difatSectors sectorSize:[self getSectorSize] length:(self.header.FATSectorsNumber > N_HEADER_FAT_ENTRY?((self.header.FATSectorsNumber - N_HEADER_FAT_ENTRY) * 4): 0)];
        
        NSMutableData *nextSecIDData = [NSMutableData data];
        nextSecIDData.length = 4;
        [difatStream read:(uint8_t *)nextSecIDData.mutableBytes maxLength:4];
        Byte *present = (Byte *)malloc(4 * sizeof(Byte));
        [nextSecIDData getBytes:present length:4];
        if (present) {
            nextSecID = [self getIntFromBytes:present];
            
            int i = 0;
            int nFat = N_HEADER_FAT_ENTRY;
            
            while (nFat < self.header.FATSectorsNumber)
            {
                if (difatStream.sectorPosition == (([self getSectorSize] - 4) + i * [self getSectorSize]))
                {
                    [difatStream seekToOffset:4 origin:SeekOriginCurrent];
                    i++;
                    continue;
                }
                
                Sector *sector = nil;
                if([self.sectorCollection objectForKey:[@(nextSecID) stringValue]]){
                    sector = [self.sectorCollection objectForKey:[@(nextSecID) stringValue]];
                } else {
                    sector = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:[self getSectorSize]];
                    sector.sectorType = SectorTypeDIFAT;
                    sector.identifier = nextSecID;
                    [self.sectorCollection setObject:sector forKey:[@(nextSecID) stringValue]];
                }
                
                [FATSectorChain addObject:sector];
                
                [difatStream read:(uint8_t *)nextSecIDData.mutableBytes maxLength:4];
                present[0] = 0;
                present[1] = 0;
                present[2] = 0;
                present[3] = 0;
                [nextSecIDData getBytes:present length:4];
                nextSecID = [self getIntFromBytes:present];
                nFat++;
                
            }
        }
        free(present);
    }
    return FATSectorChain;
}

- (NSArray *)getNormalSectorChain:(int)secID
{
    NSMutableArray *normalSectorChain = [[NSMutableArray alloc] init];
    
    int nextSecID = secID;
    NSArray *FATSectors = [self getFATSectorChain];
    
    StreamHandle *FATstream = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:FATSectors sectorSize:[self getSectorSize] length:(FATSectors.count * [self getSectorSize])];
    
    while (true)
    {
        if ((int)nextSecID == ENDOFCHAIN) {
            break;
        }
        
        if (nextSecID >= n_sector) {
            break;
        }
        
        Sector *sector = nil;
        if([self.sectorCollection objectForKey:[@(nextSecID) stringValue]]){
            sector = [self.sectorCollection objectForKey:[@(nextSecID) stringValue]];
        } else {
            sector = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:[self getSectorSize]];
            sector.sectorType = SectorTypeDIFAT;
            sector.identifier = nextSecID;
            [self.sectorCollection setObject:sector forKey:[@(nextSecID) stringValue]];
        }
        
        [normalSectorChain addObject:sector];
        
        [FATstream seekToOffset:(nextSecID * 4) origin:SeekOriginBegin];
        int next = [FATstream readInt32];
        if (next != nextSecID) {
            nextSecID = next;
        }
    }
    return normalSectorChain;
}

- (NSArray *)getMiniSectorChain:(int)secID
{
    NSMutableArray *miniSectorChain = [NSMutableArray array];
    
    if (secID != ENDOFCHAIN)
    {
        int nextSecID = secID;
        
        NSArray *miniFAT = [self getNormalSectorChain:(int)self.header.firstMiniFATSectorID];
        NSArray *miniStream = [self getNormalSectorChain:[(DirectoryEntry *)[self.directoryEntries pointerAtIndex:0] startSectC]];
        
        StreamHandle *miniFATView = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:miniFAT sectorSize:[self getSectorSize] length:(self.header.miniFATSectorsNumber * MINISECTOR_SIZE)];
        
        StreamHandle *miniStreamView = [[StreamHandle alloc] initWithFileStream:self.fileInputStream andSectorChian:miniStream sectorSize:[self getSectorSize] length:[(DirectoryEntry *)[self.directoryEntries pointerAtIndex:0] sizeOfEntry]];
        
        nextSecID = secID;
        
        while (true)
        {
            if (nextSecID == ENDOFCHAIN)
                break;
            
            Sector *ms = [[Sector alloc] initWithFileStream:self.fileInputStream andSize:MINISECTOR_SIZE];
            
            ms.identifier = nextSecID;
            ms.sectorType = SectorTypeMini;
            
            [miniStreamView seekToOffset:(nextSecID * MINISECTOR_SIZE) origin:SeekOriginBegin];
            
            uint8_t *inputBuf = malloc(sizeof(uint8_t) * MINISECTOR_SIZE);
            
            [miniStreamView read:inputBuf maxLength:MINISECTOR_SIZE];
            
            ms.inputData = [NSData dataWithBytes:inputBuf length:MINISECTOR_SIZE];
            
            free(inputBuf);
            
            [miniSectorChain addObject:ms];
            
            [miniFATView seekToOffset:(nextSecID * 4) origin:SeekOriginBegin];
            nextSecID = [miniFATView readInt32];
        }
    }
    return miniSectorChain;
}

#pragma mark - private

- (NSInteger)getSectorSize
{
    return 2 << (self.header.sectorShift - 1);
}

- (int)getIntFromBytes:(Byte *)bytes
{
    int retVal = 0;
    retVal = (retVal << 8) + bytes[3];
    retVal = (retVal << 8) + bytes[2];
    retVal = (retVal << 8) + bytes[1];
    retVal = (retVal << 8) + bytes[0];
    return retVal;
}

#pragma mark - Sort array in RED/BLACK tree fashion

- (void)loadRedBlackBinaryTreeFromDirectories
{
    DirectoryEntry *rootEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:0];
    if (rootEntry.child != NOSTREAM) {
        if ( rootEntry.nodeType == NodeTypeInvalid) {
            return;
        }
        _childSID = rootEntry.child;
        
        _rootStorage = [[Storage alloc] initWithStorageDirectoryEntry:rootEntry];
        _rootStorage.storageName = @"Root Entry";
        
        //Load the entire storage deep first...
        [self loadSiblingsT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:rootEntry.child] childId:rootEntry.child]; //todo_Irm temp changes

    }
}

- (void)loadSiblings:(DirectoryEntry *)directoryEntry inStorage:(Storage *)parentStorage
{
    if (directoryEntry.leftSibling != NOSTREAM) {
        [self loadSiblingsFromEntry:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.leftSibling] inStorage:parentStorage];
    }
    
    if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:_childSID] nodeType] == NodeTypeStream) {
        Stream *stream = [[Stream alloc] init];
        stream.sIdentifier = _childSID;
        stream.propertyKey = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:_childSID] name];
        [parentStorage addStream:stream];
    } else if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:_childSID] nodeType] == NodeTypeStorage) {
        DirectoryEntry *dirEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:_childSID];
        Storage *storage = [[Storage alloc] initWithStorageDirectoryEntry:dirEntry];
        storage.storageName = [dirEntry name];
        [parentStorage addStorage:storage];
        if (dirEntry.child != FREESECT) {
            _childSID = dirEntry.child;
            [self loadSiblings:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:dirEntry.child] inStorage:storage];
        }
    }
    
    if (directoryEntry.rightSibling != NOSTREAM) {
        [self loadSiblingsFromEntry:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.rightSibling] inStorage:parentStorage];
    }
}

- (void)loadSiblingsFromEntry:(DirectoryEntry *)directoryEntry inStorage:(Storage *)parentStorage
{
    if ([self isValidEntry:directoryEntry.leftSibling]) {
        [self loadSiblingsFromEntry:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.leftSibling] inStorage:parentStorage];
    }
    
    if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] nodeType] == NodeTypeStream) {
        Stream *stream = [[Stream alloc] init];
        stream.sIdentifier = directoryEntry.sIdentifier;
        stream.propertyKey = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] name];
        [parentStorage addStream:stream];
    } else if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] nodeType] == NodeTypeStorage) {
        DirectoryEntry *dirEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier];
        Storage *storage = [[Storage alloc] initWithStorageDirectoryEntry:dirEntry];
        storage.storageName = [dirEntry name];
        [parentStorage addStorage:storage];
        if (dirEntry.child != FREESECT) {
            _childSID = dirEntry.child;
            [self loadSiblings:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:dirEntry.child] inStorage:storage];
        }
    }
    
    if ([self isValidEntry:directoryEntry.rightSibling]) {
        [self loadSiblingsFromEntry:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.rightSibling] inStorage:parentStorage];
    }
}

- (BOOL)isValidEntry:(NSInteger)sid
{
    BOOL isValid = YES;
    if (sid != NOSTREAM) {
        if (sid > self.directoryEntries.count) {
            isValid = NO;
        }
        if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:sid] nodeType] == NodeTypeInvalid) {
            isValid = NO;
        }
    } else {
        isValid = NO;
    }
    return isValid;
}

- (void)closeFile
{
    [_fileInputStream close], _fileInputStream = nil;
    _directoryEntries = nil;
    _sectorCollection = nil;
    _header = nil;
    _rootStorage = nil;
}


- (BOOL) checkDirectoryEntryPresent : (NSString*)directoryName {
    
    if (![self.directoryEntries count]) {
        
        if (![self isValidHeader:nil]) {
            return NO;
        }
        
        [self populateDirectories];
    }
    int count = [self.directoryEntries count];
    for(int index = 0; index <count ; index++)
    {
        NSString* name = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:index] name];
        if ([name isEqualToString:directoryName]) {
            return YES;
        }
    }
    return NO;
}
- (void)loadSiblingstemp:(DirectoryEntry *)directoryEntry inStorage:(Storage *)parentStorage
{
    int count = [self.directoryEntries count];
    for(int index = 0; index <count ; index++)
    {
        NSString* name = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:index] name];
        if (  [name isEqualToString:@"EncryptedPackage"]) {
            Stream *stream = [[Stream alloc] init];
            stream.sIdentifier = _childSID;
            stream.propertyKey = name;//[(DirectoryEntry *)[self.directoryEntries pointerAtIndex:_childSID] name];
            
            [parentStorage addStream:stream];
        }
    }
}

- (void)loadSiblingsT:(DirectoryEntry *)directoryEntry childId : (NSInteger)childSID
{
    if (directoryEntry.leftSibling != NOSTREAM) {
        [self loadSiblingsFromEntryT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.leftSibling] childId:childSID ];
    }
    
    if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:childSID] nodeType] == NodeTypeStream) {
        Stream *stream = [[Stream alloc] init];
        stream.sIdentifier = childSID;
        stream.propertyKey = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:childSID] name];
        [self.rootStorage addStream:stream];
    } else if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:childSID] nodeType] == NodeTypeStorage) {
        DirectoryEntry *dirEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:childSID];
        Storage *storage = [[Storage alloc] initWithStorageDirectoryEntry:dirEntry];
        storage.storageName = [dirEntry name];
        [self.rootStorage addStorage:storage];
        if (dirEntry.child != FREESECT) {
            childSID = dirEntry.child;
            [self loadSiblingsT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:dirEntry.child] childId:childSID  ];
        }
    }
    
    if (directoryEntry.rightSibling != NOSTREAM) {
        [self loadSiblingsFromEntryT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.rightSibling] childId:childSID ];
    }
}

- (void)loadSiblingsFromEntryT:(DirectoryEntry *)directoryEntry childId : (NSInteger)childSID
{
    if ([self isValidEntry:directoryEntry.leftSibling]) {
        [self loadSiblingsFromEntryT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.leftSibling] childId:childSID ];
    }
    
    if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] nodeType] == NodeTypeStream) {
        Stream *stream = [[Stream alloc] init];
        stream.sIdentifier = directoryEntry.sIdentifier;
        stream.propertyKey = [(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] name];
        [self.rootStorage addStream:stream];
    } else if ([(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier] nodeType] == NodeTypeStorage) {
        DirectoryEntry *dirEntry = (DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.sIdentifier];
        Storage *storage = [[Storage alloc] initWithStorageDirectoryEntry:dirEntry];
        storage.storageName = [dirEntry name];
        [self.rootStorage addStorage:storage];
        if (dirEntry.child != FREESECT) {
            childSID = dirEntry.child;
            [self loadSiblingsT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:dirEntry.child] childId:childSID  ];
        }
    }
    
    if ([self isValidEntry:directoryEntry.rightSibling]) {
        [self loadSiblingsFromEntryT:(DirectoryEntry *)[self.directoryEntries pointerAtIndex:directoryEntry.rightSibling] childId:childSID  ];
    }
}



@end

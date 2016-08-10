/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  RTFEnums.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    RtfAlignmentLeft,
    RtfAlignmentCenter,
    RtfAlignmentRight,
    RtfAlignmentJustify
} RtfAlignment;

typedef enum
{
    RtfPictureTypeEmfblip,
    RtfPictureTypePngblip,
    RtfPictureTypeJpegblip,
    RtfPictureTypeMacpict,
    RtfPictureTypePmmetafile,
    RtfPictureTypeWmetafile,
    RtfPictureTypeDibitmap,
    RtfPictureTypeWbitmap
} RtfPictureType;

typedef enum
{
    RtfObjectTypeEmb,
    RtfObjectTypeLink,
    RtfObjectTypeAutLink,
    RtfObjectTypeSub,
    RtfObjectTypePub,
    RtfObjectTypeIcemb,
    RtfObjectTypeHtml,
    RtfObjectTypeOcx
} RtfObjectType;

typedef enum
{
    RtfTokenTypeNone,
    RtfTokenTypeKeyword,
    RtfTokenTypeExtKeyword,
    RtfTokenTypeControl,
    RtfTokenTypeText,
    RtfTokenTypeEof,
    RtfTokenTypeGroupStart,
    RtfTokenTypeGroupEnd
} RtfTokenType;

typedef enum
{
    RtfDomFieldMethodNone,
    RtfDomFieldMethodDirty,
    RtfDomFieldMethodEdit,
    RtfDomFieldMethodLock,
    RtfDomFieldMethodPriv,
} RtfDomFieldMethod;

typedef enum
{
    RtfNodeTypeRoot,
    RtfNodeTypeKeyword,
    RtfNodeTypeExtKeyword,
    RtfNodeTypeControl,
    RtfNodeTypeText,
    RtfNodeTypeGroup,
    RtfNodeTypeNone
} RtfNodeType;

typedef enum
{
    RtfVerticalAlignmentTop,
    RtfVerticalAlignmentMiddle,
    RtfVerticalAlignmentBottom
} RtfVerticalAlignment;

typedef enum
{
    RtfLevelNumberTypeNone = -10,
    RtfLevelNumberTypeArabic = 0,
    RtfLevelNumberTypeUppercaseRomanNumeral = 1,
    RtfLevelNumberTypeLowercaseRomanNumeral = 2,
    RtfLevelNumberTypeUppercaseLetter = 3,
    RtfLevelNumberTypeLowercaseLetter = 4,
    RtfLevelNumberTypeOrdinalNumber = 5,
    RtfLevelNumberTypeCardinalTextNumber = 6,
    RtfLevelNumberTypeOrdinalTextNumber = 7,
    RtfLevelNumberTypeKanjiNumberingWithoutTheDigitCharacter = 10,
    RtfLevelNumberTypeKanjiNumberingWithTheDigitCharacte = 11,
    RtfLevelNumberType_46_phonetic_double_byte_katakana_characters_aiueo_dbchar = 20,
    RtfLevelNumberType_46_phonetic_double_byte_katakana_characters_iroha_dbchar = 21,
    RtfLevelNumberType_46_phonetic_katakana_characters_in_aiueo_order = 12,
    RtfLevelNumberType_46_phonetic_katakana_characters_in_iroha_order = 13,
    RtfLevelNumberTypeDoubleByteCharacter = 14,
    RtfLevelNumberTypeSingleByteCharacter = 15,
    RtfLevelNumberTypeKanjiNumbering3 = 16,
    RtfLevelNumberTypeKanjiNumbering4 = 17,
    RtfLevelNumberTypeCircleNumbering = 18,
    RtfLevelNumberTypeDoubleByteArabicNumbering = 19,
    RtfLevelNumberTypeArabicWithLeadingZero = 22,
    RtfLevelNumberTypeBullet = 23,
    RtfLevelNumberTypeKoreanNumbering2 = 24,
    RtfLevelNumberTypeKoreanNumbering1 = 25,
    RtfLevelNumberTypeChineseNumbering1 = 26,
    RtfLevelNumberTypeChineseNumbering2 = 27,
    RtfLevelNumberTypeChineseNumbering3 = 28,
    RtfLevelNumberTypeChineseNumbering4 = 29,
    RtfLevelNumberTypeChineseZodiacNumbering1 = 30,
    RtfLevelNumberTypeChineseZodiacNumbering2 = 31,
    RtfLevelNumberTypeChineseZodiacNumbering3 = 32,
    RtfLevelNumberTypeTaiwaneseDoubleByteNumbering1 = 33,
    RtfLevelNumberTypeTaiwaneseDoubleByteNumbering2 = 34,
    RtfLevelNumberTypeTaiwaneseDoubleByteNumbering3 = 35,
    RtfLevelNumberTypeTaiwaneseDoubleByteNumbering4 = 36,
    RtfLevelNumberTypeChineseDoubleByteNumbering1 = 37,
    RtfLevelNumberTypeChineseDoubleByteNumbering2 = 38,
    RtfLevelNumberTypeChineseDoubleByteNumbering3 = 39,
    RtfLevelNumberTypeChineseDoubleByteNumbering4 = 40,
    RtfLevelNumberTypeKoreanDoubleByteNumbering1 = 41,
    RtfLevelNumberTypeKoreanDoubleByteNumbering2 = 42,
    RtfLevelNumberTypeKoreanDoubleByteNumbering3 = 43,
    RtfLevelNumberTypeKoreanDoubleByteNumbering4 = 44,
    RtfLevelNumberTypeHebrewNonStandardDecimal = 45,
    RtfLevelNumberTypeArabicAlifBaTah = 46,
    RtfLevelNumberTypeHebrewBiblicalStandard = 47,
    RtfLevelNumberTypeArabicAbjadStyle = 48,
    RtfLevelNumberTypeNoNumber = 255
} RtfLevelNumberType;

typedef enum
{
    RtfHeaderFooterStyleAllPages,
    RtfHeaderFooterStyleLeftPages,
    RtfHeaderFooterStyleRightPages,
    RtfHeaderFooterStyleFirstPage
} RtfHeaderFooterStyle;
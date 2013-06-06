TMXMLSerialization
==================

Human readability oriented XML serialization and deserialization in Objective-c  .

Sample
=============

For xml like this:

    <class>
        <student sid="123">
            <name>Annie</name>
            <age>12</age>
        </student>
        <student sid="234">
            <name>Bob</name>
            <age>12</age>
        </student>
    </class>

You can write the code that define the data structure like this:

    #import "TMSerializable.h"
    
    @interface Student: NSObject <TMSerializable>

    TM_SERIALIZABLE_PROPERTY(copy, NSString*, sid)
    TM_SERIALIZABLE_PROPERTY(copy, NSString*, name)
    TM_SERIALIZABLE_PROPERTY(assign, NSInteger, age)

    @end

    @interface ClassData : NSObject <TMSerializable>

    TM_LIST_PROPERTY(Student*, student);

    @end

And give the implementation in the corresponding .m file:

    @implementation Student

    TM_SERIALIZABLE_SYNTHESIZE(NSString*, sid)
    TM_SERIALIZABLE_SYNTHESIZE(NSString*, name)
    TM_SERIALIZABLE_SYNTHESIZE(NSInteger, age)

    @end

    @implementation ClassData

    TM_LIST_SYNTHESIZE（Student*, student)

    @end

Run the code below to parse the xml.

    TMXMLSerializer *xmlSerializer = [[TMXMLSerializer alloc] initWithRootObjectClass:CLassData.class];
    ClassData *obj = [[ClassData alloc] init];
    NSError* e = [xmlSerializer deserialize:[testXML dataUsingEncoding:NSUTF8StringEncoding] intoObject:obj];


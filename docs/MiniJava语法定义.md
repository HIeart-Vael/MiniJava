# 规则（标识符 & 数字 & EOF）

## **Identifier（标识符）：**

> Identifier is one or more letters, digits, and underscores, starting with a letter

以字母开头，含字母、数字、下划线

##### 

##### **正确的ID：**

```
abc abc_ abc123 abc_123
```

##### 

##### **xtext实现：ID_**

```
terminal ID_:
    ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'_'| INT)*
;
```



## **Integer Literal（整型常量）**

> IntegerLiteral is one or more decimal digits

整数是一个或多个十进制数字

##### 

##### **正确的INT**

```
9 99 999 ...
```

##### 

##### **xtext实现：INT**

```
terminal INT returns ecore::EInt: ('0'..'9')+;
```



## **Double Literal（浮点型常量）**

> DoubleLiteral = IntegerLiteral "." IntegerLiteral? | IntegerLiteral? "." IntegerLiteral

##### 

##### **正确的Double**

```
99.99 99. .99
```



## **EOF**

> EOF is a distinguished token returned by the scanner at end-of-file

是扫描程序在文件末尾返回的可分辨令牌



# 前置定义（短语，语句）

## **QualifiedName（修饰名、限定名）**

> QualifiedName = Identifier | QualifiedName "." Identifier

###### 

###### **示例代码：**

```
Scanner
java.util.Scanner
```

也就是QName = ID | ID.ID | ID.ID.ID | ... 或 QName = ID('.'ID)*

### *QualifiedNameList

> QualifiedNameList = QualifiedName | QualifiedNameList "," QualifiedName

即QNList = QName('.'QName)*



## **VarDecl（声明语句）**

> VarDecl = Type Identifier



### *VarList

> VarList = VarDecl | VarList "," VarDecl

### *Type

> Type = "int" 

> | "boolean" 

> | "void" 

> | "double" 

> | "char" |

>  QualifiedName 

> | Type "[" "]" 

> | "(" VarList ")" % 元组类型，表示一个有类型的，不可更改的n元组对象

###### 

###### **示例代码：**

```
int a
boolean sign
void func
double num
Number number        //QualifiedName Identifier
int[] array          //Type "[" "]" Identifier
(int, double) abc
```

以上组合均为合法的VarDecl



## **##Statement（语句）##**

> Statement = 

> "{" (Statement)* "}" 

> | "return" Expression? ";" 

> | "if" "(" Expression ")" 

> Statement 

> ("else" Statement)? 

> | "while" "(" Expression ")" 

> Statement 

> | VarDecl ";" 

> | LValueExp "=" Expression ";"



### ***LValueExp（左值表达式?）**

> LValueExp = Identifier 

> | Expression "." Identifier 

> | Expression "[" Expression "]"



### ***Expression（表达式）**

> Expression = 

> Expression ( "&&" | "<" | "+" | "-" | "*" ) Expression* 

> *| LValueExp | Expression "." Identifier "(" (Expression ("," Expression)*)? ")" 

> | IntegerLiteral 

> | DoubleLiteral 

> | "true" 

> | "false" 

> | "null" 

> | "" 

> | """ (\"|\[.])* """                  % 字符串，中间可包括任意字符和转移字符 

> | "'" (\"|\[.]) "'" 

> | Identifier 

> | "this" 

> | "super"                     % super不能单独使用 

> | "new" Type ("[" Expression "]")? 

> | "new" QualifiedName "(" ")" 

> | "!" Expression 

> | "(" Expression ")" 

> | "(" Identifier ':' Expression ("," Identifier ':' Expression)+ ")"     % n元组实例，如(a:1,b:2)

以上.



# 声明（PackageDecl、ImportDecl、ClassDecl）

> Goal = PackageDecl? ImportDecl* x ClassDecl* EOF

可能存在包声明（零个或一个），零个或多个import声明，零个或多个class声明



## **PackageDecl（包声明）**

> PackageDecl = "package" QualifiedName ";"

##### 

##### **示例代码：**

```
package animals;
package net.java.util;
```



## **ImportDecl（模块导入声明）**

> ImportDecl = "import" QualifiedName ";"

##### 

##### **示例代码：**

```
import java.util.Scanner;
import java.io.FileReader;
```



## **MainClass**

> MainClass = "class" Identifier "{" "public" "static" "void" "main" "(" "String" "[" "]" Identifier ")" "{" Statement "}" "}"

##### 

##### **示例代码：**

```
class HelloWorld {
    public static void main(String[] args) {
        Statement
    }
}
```



## **ClassDecl（类声明）**

> ClassDecl = "class" Identifier ("extends" QualifiedName)? ("implements" QualifiedNameList)? "{" (VarDecl ";" | MethodDecl)* "}"

##### 

##### **示例代码:**

```
class ID (extends QName)? (implements QNList)? {
    VarDecl ;
    MethodDecl //见下
}
```



### ***MethodDecl(类方法)**

> MethodDecl = ("public"|"protected"|"private") Type Identifier "(" VarList? ")" "{" (Statement)* "}"

###### 

###### **示例代码:**

```
public:
int function(int a, int b) {
Statement
}
```



部分xtext实现后续补上，或新建文档说明。


.Model small
.stack 100h
.data
msg1 db 13,10,"enter the frist num of the arithmetic series $"
msg2 db 13,10,"enter the change in the arithmetic series $"
msg3 db 13,10,"enter the size of the arithmetic series $" 
msg4 db 13,10,"this is not a number, enter a number $"
crlf db 13,10,"$"
msg5 db 13,10,"enter a num that you think that its in the arithmetic series $"
msg6 db 13,10,"yes! the num is in the arithmetic series $"
msg7 db 13,10,"no, the num is not in the arithmetic series $"
 
current_number db 4 dup(0h)
endThePrinting db ' $';; for print the current number with a space
change_number db 0 
size_number db 0  
test_number db 5,?,5 dup(0h)
ans db 0

.code
mov ax,@data
mov ds,ax
xor ax,ax 
jmp start 

CheckIfThisIsANumberAndMakeItDecNum proc
push bp
mov bp,sp
push ax
push dx
push si
 
mov si,bp+6;; in si there is the offset of the num
Checking:
cmp ds:si,30h
jb invalid

cmp ds:si,39h
ja invalid

sub ds:si,30h
jmp ending1

invalid:
mov dx,bp+4;; in dx there is the offset of msg4
mov ah,09h
int 21h

mov ah,01h
int 21h
mov ds:si,ax
jmp Checking

ending1:

pop si
pop dx
pop ax
pop bp
ret 
CheckIfThisIsANumberAndMakeItDecNum endp

 
menu proc 
push bp
mov bp,sp
push ax
push dx
push bx
    
mov dx,[bp+6] ;;in dx there is the offset of msg3
mov ah,09h
int 21h

mov bx,[bp+4] ;;in bx there is the offset of the num
mov ah,01h
int 21h
mov ds:bx,al

pop bx
pop dx
pop ax
pop bp
ret ;; i want to keep the offset of the number to use it in "CheckIfThisIsANumberAndMakeItDecNum"
menu endp 

add_num proc
push bp
mov bp,sp
push si
push ax
push bx
push dx
mov si,[bp+4];; move to ax the offset of the delta num
mov bx,[bp+6];; move to bx the offset of the current num
mov al,[byte ptr ds:si]
 

adding:
add ds:bx,al ;; add cant work with 2 memories
jmp CheckIfTheNumIsBiggerThen10   

CheckIfTheNumIsBiggerThen10:
mov dl,[byte ptr ds:bx];;to keep it for count
cmp ds:bx,3ah
jae TheNumIsBiggerThen10 
jmp ending2

TheNumIsBiggerThen10:
dec bx
cmp ds:bx,30h
jae JustInc
add ds:bx,30h 
JustInc:  
inc ds:bx
jmp count

count:
inc bx
cmp bx,[bp+6]-3  ;; if its 4 digits number...
ja ending2 
mov ds:bx,dl
sub ds:bx,0ah
dec bx
jmp CheckIfTheNumIsBiggerThen10 

ending2:
pop dx
pop bx
pop ax
pop si
pop bp
ret  ;; keeps current_number and change_number offset
add_num endp

FillTestNum proc
push bp
mov bp,sp
push si
push ax
push bx 
push dx
push cx
xor ax,ax
xor cx,cx
mov bx,[bp+4];; test_num(offset)
mov cx,4 

CheckHowMuchdigitsThereIs: 
cmp ds:bx,0dh
je Add1
cmp ds:bx,0h
je Add1 
jmp looping
Add1: 
mov ds:bx,0h 
inc ax

looping:
inc bx
loop CheckHowMuchdigitsThereIs
cmp ax,0h
je ending4

mov cx,4
mov bx,[bp+4]
sub cx,ax;;in cx there is the nums of the digits in the number 
add bx,cx
dec bx;;in bx there is the offset of the lost digit of the number 

MoveTheDigitsASide:
mov si, bx
add si,ax;;in si there is the offset of where the digit need to move to
mov dl,[byte ptr ds:bx] 
mov ds:si,dl
mov ds:bx,0h
dec bx
loop MoveTheDigitsASide

ending4: 
pop cx
pop dx
pop bx
pop ax
pop si
pop bp
ret 6
FillTestNum endp 

CmpNumbers proc
push bp
mov bp,sp
push si
push ax
push bx
push cx
push dx
push di
mov di,[bp+6];;test_number(offset)
mov bx,[bp+8];;current_number(offset)
mov cx,4
mov si,[bp+4];;ans(offset)

check:
xor ax,ax
mov al,[byte ptr ds:di]
cmp ds:bx,al ;; we cant do memory to memory in cmp
jb AnsIs1
ja AnsIs3
inc di
inc bx ;; to go to the next digit
loop check 
mov [byte ptr ds:si],02h 
jmp ending3 

AnsIs1:
mov [byte ptr ds:si],01h
jmp ending3

AnsIs3:
mov [byte ptr ds:si],03h

ending3:     
;; if current_number is bigger: ans=3 , test_number is bigger: ans=1,test_number=current_number: ans=2
pop di
pop dx
pop cx
pop bx
pop ax
pop si
pop bp
ret 6
CmpNumbers endp     

start:
push offset msg1
lea bx,current_number+3
push bx 
call menu 
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum
 
push offset msg2  
lea bx,change_number
push bx
call menu
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum

push offset msg3
lea bx,size_number
push bx
call menu  
lea bx,msg4
push bx
call CheckIfThisIsANumberAndMakeItDecNum 

lea dx,crlf
mov ah,09h  
int 21h

xor cx,cx
mov cl,size_number
lea dx,current_number+3
push dx   
lea bx, change_number
push bx
add current_number+3,30h ;; to print the number   

PrinTheAritmaticSeries:  
call add_num
lea dx,current_number 
mov ah,09h  ;; print the current num with space
int 21h 
loop PrinTheAritmaticSeries 

lea dx,msg5
mov ah,09h
int 21h 

mov cx,4
lea dx,test_number 
mov ah, 0ah
int 21h
add dx,2
push dx
call FillTestNum

CheckIfTheNumIsIN:
lea dx,test_number 
add dx,2;; the start of the test_number 
push dx ;; test_number(offset)
lea dx,current_number
push dx;;current_number(offset)  
lea dx,ans
push dx;;ans(offset) 
Call CmpNumbers

cmp ans,2
jb ItsNot
ja running
lea dx,msg6
mov ah,09h
int 21h
jmp EndOf  
ItsNot:
lea dx,msg7
mov ah,09h
int 21h
jmp EndOf
running: 
lea dx,current_number+3
push dx;;current num
lea dx,change_number
push dx       
call add_num
jmp CheckIfTheNumIsIN

EndOf: 
end
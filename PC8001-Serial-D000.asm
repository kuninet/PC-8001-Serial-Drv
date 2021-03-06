;
; PC-8001内蔵シリアルドライバー(割り込みなし)
;
	CPU	Z80

TARGET:	equ	"Z80"

UARTRD	EQU	20H
UARTRC	EQU	21H
;
BUFSIZ	EQU	80H
;
RTSHIG	EQU	00010111B
RTSLOW	EQU	00110111B
;
;
CR	EQU	0DH
LF	EQU	0AH
;
    org 0D000h
;
; 各ルーチンへのエントリーテーブル
;
    JP  INIT8251
    JP  SERIAL_READ
    JP  SERIAL_WRITE
    JP  RET_CMT
;
; 8251 シリアルLSI初期化
;
INIT8251:
	XOR	A
	OUT	(UARTRC),A
	OUT	(UARTRC),A
	OUT	(UARTRC),A
    LD  A,(HL)
;	LD	A,01000000B
	OUT	(UARTRC),A
    INC HL
    LD  A,(HL)
;	LD	A,01001110B
	OUT	(UARTRC),A
	LD	A,RTSLOW
	OUT	(UARTRC),A
;
;  PC-8001の8251を外部RS232Cヘ
;
    LD  A,(0EA66h)  ; ワークエリアから I/O 30hへ出力する情報を取得
    AND A,0CFh
    OR  A,20h      ; BS2 = ON
    OUT (30h),A    ; CMTから外部RS232Cへ切り替え
;
    RET
;
; 8251をCMT側へ戻す
;
RET_CMT:
    LD  A,(0EA66h)  ; ワークエリアから I/O 30hへ出力する情報を取得
    AND A,0CFh
    OUT (30h),A    ; 外部RS232CからCMTへ切り替え
    RET
;
; USR関数から渡ってきたストリングディスクリプタ情報を取得
;
STR_DISC_SETUP:
    LD (DISC_LEN_PTR),DE
    LD A,(DE)   ; 文字列長取得
    LD C,A      ; 文字列カウンタはCレジスタ
    INC DE
    LD A,(DE)
    LD L,A
    INC DE
    LD A,(DE)
    LD H,A      ; HLレジスタへ文字列ポインタを入れる
    LD (DISC_PTR),HL
    RET
;
; USR関数 シリアル受信(ポーリング)
;
SERIAL_READ:
    CALL STR_DISC_SETUP
;
    LD HL,SERBUF
    LD C,0
SERIAL_READ1:
    CALL CHAR_IN
;
    CP CR
    JP Z,SERIAL_READ_END ; CRコードがきたらEXIT
    CP LF
    JP Z,SERIAL_READ_END ; LFコードがきたらEXIT
;
    LD  (HL),A
    INC C
    LD A,C
    CP BUFLEN+1
    JP Z,SERIAL_READ_END ; バッファがいっぱいになったらEXIT
    INC HL
    JP  SERIAL_READ1
;
SERIAL_READ_END:
    LD A,C                     ; 文字数をストリングディスクリプタへ
    LD HL,(DISC_LEN_PTR)       ; 
    LD (HL),A
;
    LD B,0                     ; 受信文字をストリングディスクリプタが指す番地へ
    LD DE,(DISC_PTR)
    LD HL,SERBUF
    LDIR
    RET
;
; USR関数 シリアル送信
;
SERIAL_WRITE:
    CALL STR_DISC_SETUP
SERIAL_WRITE1:
    LD A,(HL)   ; 1文字取得
    CALL CHAR_OUT
    INC HL
    DEC C
    JP NZ,SERIAL_WRITE1
;
    RET

;
; 8251から1文字入力
;
CHAR_IN:
    IN  A,(UARTRC)
    AND A,02h
    JP  Z,CHAR_IN
    IN  A,(UARTRD)
    RET
;
; 8251へ1文字出力
;
CHAR_OUT:
    PUSH AF
CHAR_OUT1:
    IN A,(UARTRC)
    AND A,01h
    JP  Z,CHAR_OUT1
    POP AF
    OUT (UARTRD),A
    RET
;
;
; RAM
SERBUF	DS	BUFSIZ
BUFLEN  EQU $-SERBUF
DISC_PTR  DS 2
DISC_LEN_PTR DS 1  
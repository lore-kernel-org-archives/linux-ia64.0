From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:10:32 +0000
Subject: [PATCH] kill arc leftovers
Message-Id: <marc-linux-ia64-106467186526220@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Two ARC headers from mips sneaked into the SN2 code to get 'right' type
for an unused pointer in a structure used to communicate with the
firmware.  Replace it with a void *.


diff -Nru a/include/asm-ia64/sn/arc/hinv.h b/include/asm-ia64/sn/arc/hinv.h
--- a/include/asm-ia64/sn/arc/hinv.h	Sat Sep 27 16:06:56 2003
+++ b/include/asm-ia64/sn/arc/hinv.h	Sat Sep 27 16:06:56 2003
@@ -1,183 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-
-/* $Id$
- *
- * ARCS hardware/memory inventory/configuration and system ID definitions.
- */
-#ifndef _ASM_SN_ARC_HINV_H
-#define _ASM_SN_ARC_HINV_H
-
-#include <asm/sn/arc/types.h>
-
-/* configuration query defines */
-typedef enum configclass {
-	SystemClass,
-	ProcessorClass,
-	CacheClass,
-#ifndef	_NT_PROM
-	MemoryClass,
-	AdapterClass,
-	ControllerClass,
-	PeripheralClass
-#else	/* _NT_PROM */
-	AdapterClass,
-	ControllerClass,
-	PeripheralClass,
-	MemoryClass
-#endif	/* _NT_PROM */
-} CONFIGCLASS;
-
-typedef enum configtype {
-	ARC,
-	CPU,
-	FPU,
-	PrimaryICache,
-	PrimaryDCache,
-	SecondaryICache,
-	SecondaryDCache,
-	SecondaryCache,
-#ifndef	_NT_PROM
-	Memory,
-#endif
-	EISAAdapter,
-	TCAdapter,
-	SCSIAdapter,
-	DTIAdapter,
-	MultiFunctionAdapter,
-	DiskController,
-	TapeController,
-	CDROMController,
-	WORMController,
-	SerialController,
-	NetworkController,
-	DisplayController,
-	ParallelController,
-	PointerController,
-	KeyboardController,
-	AudioController,
-	OtherController,
-	DiskPeripheral,
-	FloppyDiskPeripheral,
-	TapePeripheral,
-	ModemPeripheral,
-	MonitorPeripheral,
-	PrinterPeripheral,
-	PointerPeripheral,
-	KeyboardPeripheral,
-	TerminalPeripheral,
-	LinePeripheral,
-	NetworkPeripheral,
-#ifdef	_NT_PROM
-	Memory,
-#endif
-	OtherPeripheral,
-
-	/* new stuff for IP30 */
-	/* added without moving anything */
-	/* except ANONYMOUS. */
-
-	XTalkAdapter,
-	PCIAdapter,
-	GIOAdapter,
-	TPUAdapter,
-	TernaryCache,
-	Anonymous
-} CONFIGTYPE;
-
-typedef enum {
-	Failed = 1,
-	ReadOnly = 2,
-	Removable = 4,
-	ConsoleIn = 8,
-	ConsoleOut = 16,
-	Input = 32,
-	Output = 64
-} IDENTIFIERFLAG;
-
-#ifndef NULL			/* for GetChild(NULL); */
-#define	NULL	0
-#endif
-
-union key_u {
-	struct {
-#ifdef	_MIPSEB
-		unsigned char  c_bsize;		/* block size in lines */
-		unsigned char  c_lsize;		/* line size in bytes/tag */
-		unsigned short c_size;		/* cache size in 4K pages */
-#else	/* _MIPSEL */
-		unsigned short c_size;		/* cache size in 4K pages */
-		unsigned char  c_lsize;		/* line size in bytes/tag */
-		unsigned char  c_bsize;		/* block size in lines */
-#endif	/* _MIPSEL */
-	} cache;
-	ULONG FullKey;
-};
-
-#if _MIPS_SIM = _ABI64
-#define SGI_ARCS_VERS	64			/* sgi 64-bit version */
-#define SGI_ARCS_REV	0			/* rev .00 */
-#else
-#define SGI_ARCS_VERS	1			/* first version */
-#define SGI_ARCS_REV	10			/* rev .10, 3/04/92 */
-#endif
-
-typedef struct component {
-	CONFIGCLASS	Class;
-	CONFIGTYPE	Type;
-	IDENTIFIERFLAG	Flags;
-	USHORT		Version;
-	USHORT		Revision;
-	ULONG 		Key;
-	ULONG		AffinityMask;
-	ULONG		ConfigurationDataSize;
-	ULONG		IdentifierLength;
-	char		*Identifier;
-} COMPONENT;
-
-/* internal structure that holds pathname parsing data */
-struct cfgdata {
-	char *name;			/* full name */
-	int minlen;			/* minimum length to match */
-	CONFIGTYPE type;		/* type of token */
-};
-
-/* System ID */
-typedef struct systemid {
-	CHAR VendorId[8];
-	CHAR ProductId[8];
-} SYSTEMID;
-
-/* memory query functions */
-typedef enum memorytype {
-	ExceptionBlock,
-	SPBPage,			/* ARCS = SystemParameterBlock */
-#ifndef	_NT_PROM
-	FreeContiguous,
-	FreeMemory,
-	BadMemory,
-	LoadedProgram,
-	FirmwareTemporary,
-	FirmwarePermanent
-#else	/* _NT_PROM */
-	FreeMemory,
-	BadMemory,
-	LoadedProgram,
-	FirmwareTemporary,
-	FirmwarePermanent,
-	FreeContiguous
-#endif	/* _NT_PROM */
-} MEMORYTYPE;
-
-typedef struct memorydescriptor {
-	MEMORYTYPE	Type;
-	LONG		BasePage;
-	LONG		PageCount;
-} MEMORYDESCRIPTOR;
-
-#endif /* _ASM_SN_ARC_HINV_H */
diff -Nru a/include/asm-ia64/sn/arc/types.h b/include/asm-ia64/sn/arc/types.h
--- a/include/asm-ia64/sn/arc/types.h	Sat Sep 27 16:06:56 2003
+++ b/include/asm-ia64/sn/arc/types.h	Sat Sep 27 16:06:56 2003
@@ -1,41 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 1999,2001-2003 Silicon Graphics, Inc.  All Rights Reserved.
- * Copyright 1999 Ralf Baechle (ralf@gnu.org)
- */
-#ifndef _ASM_SN_ARC_TYPES_H
-#define _ASM_SN_ARC_TYPES_H
-
-typedef char		CHAR;
-typedef short		SHORT;
-typedef long		LARGE_INTEGER __attribute__ ((__mode__ (__DI__)));
-typedef	long		LONG __attribute__ ((__mode__ (__DI__)));
-typedef unsigned char	UCHAR;
-typedef unsigned short	USHORT;
-typedef unsigned long	ULONG __attribute__ ((__mode__ (__DI__)));
-typedef void		VOID;
-
-/* The pointer types.  We're 64-bit and the firmware is also 64-bit, so
-   live is sane ...  */
-typedef CHAR		*_PCHAR;
-typedef SHORT		*_PSHORT;
-typedef LARGE_INTEGER	*_PLARGE_INTEGER;
-typedef	LONG		*_PLONG;
-typedef UCHAR		*_PUCHAR;
-typedef USHORT		*_PUSHORT;
-typedef ULONG		*_PULONG;
-typedef VOID		*_PVOID;
-
-typedef CHAR		*PCHAR;
-typedef SHORT		*PSHORT;
-typedef LARGE_INTEGER	*PLARGE_INTEGER;
-typedef	LONG		*PLONG;
-typedef UCHAR		*PUCHAR;
-typedef USHORT		*PUSHORT;
-typedef ULONG		*PULONG;
-typedef VOID		*PVOID;
-
-#endif /* _ASM_SN_ARC_TYPES_H */
diff -Nru a/include/asm-ia64/sn/klconfig.h b/include/asm-ia64/sn/klconfig.h
--- a/include/asm-ia64/sn/klconfig.h	Sat Sep 27 16:06:56 2003
+++ b/include/asm-ia64/sn/klconfig.h	Sat Sep 27 16:06:56 2003
@@ -41,7 +41,6 @@
 #include <asm/sn/sgi.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/vector.h>
-#include <asm/sn/arc/hinv.h>
 #include <asm/sn/xtalk/xbow.h>
 #include <asm/sn/xtalk/xtalk.h>
 #include <asm/sn/kldir.h>
@@ -515,10 +514,10 @@
 	nasid_t		nasid;            /* node number - from parent */
 	char		pad1;		  /* pad out structure. */
 	char		pad2;		  /* pad out structure. */
-	COMPONENT	*arcs_compt;      /* ptr to the arcs struct for ease*/
+	void		*__pad3;          /* was unused arc COMPONENT ptr */
         klconf_off_t	errinfo;          /* component specific errors */
-        unsigned short  pad3;             /* pci fields have moved over to */
-        unsigned short  pad4;             /* klbri_t */
+        unsigned short  pad4;             /* pci fields have moved over to */
+        unsigned short  pad5;             /* klbri_t */
 } klinfo_t ;
 
 #define KLCONFIG_INFO_ENABLED(_i)	((_i)->flags & KLINFO_ENABLE)

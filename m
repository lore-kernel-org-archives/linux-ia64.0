From: Gerrit Huizenga <gerrit@us.ibm.com>
Date: Mon, 05 Mar 2001 15:17:53 +0000
Subject: [Linux-ia64] console on serial port for Lion, B3, BIOS 71
Message-Id: <marc-linux-ia64-105590693005245@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone been able to configure the serial port for console operations
with BIOS 71?  It appears on several of my Lions that the EFI screen for
managing redirection of EFI, etc. to the serial console are gone with
BIOS 71 & EFI 1.02.  It looks like the EFI code has changed pretty dramatically
here (serial port console is all in the drivers subdir, rather than the
core firmware).  The Boot Manager's menu options no longer allow for
speed/parity configuration on the console ports, and there is a reference
in the BIOS that there is a lurking serial port bug with console redirection.

I can see that there are EFI driver entries and the GUID's are registered for:

	ConIn-8be4df61-93ca-11d2-aa0d-00e098032b8c
	ConInDev-8be4df61-93ca-11d2-aa0d-00e098032b8c
	ConOut-8be4df61-93ca-11d2-aa0d-00e098032b8c
	ConOutDev-8be4df61-93ca-11d2-aa0d-00e098032b8c
	DevIo-47c7b226-c42a-11d2-8e57-00a0c969723b
	ErrOut-8be4df61-93ca-11d2-aa0d-00e098032b8c
	ErrOutDev-8be4df61-93ca-11d2-aa0d-00e098032b8c
	ErrOutSplit-47c7b226-c42a-11d2-8e57-00a0c969723b
	PcAnsi-47c7b226-c42a-11d2-8e57-00a0c969723b
	TxtInSplit-47c7b226-c42a-11d2-8e57-00a0c969723b
	TxtOutSplit-47c7b226-c42a-11d2-8e57-00a0c969723b
	Vt100-47c7b226-c42a-11d2-8e57-00a0c969723b
	serialio-47c7b226-c42a-11d2-8e57-00a0c969723b
	txtin-47c7b226-c42a-11d2-8e57-00a0c969723b
	txtout-47c7b226-c42a-11d2-8e57-00a0c969723b

Where the "Split" functions appear to be the ones that also route data
to the serial port (this info thanks to the new efivars patch ;-).  However,
I can't seem to read the variables (Unicode, plus oddly encoded) although
it seems like the baud rate may be set to 115384, rather than the more
common 115200.  I can seem to get DCD or DSR signals on my serial port
but no data or noise on the transmit/receive lines.

It seems like *something* needs to be done to configure the Spliters
but I can't seem to figure out what it is.  I also can't seem to get
a getty running on those lines - my previous config worked fine but
it no longer works after updating procs to B3, Bios to 71 and EFI to
1.02.

Any help would be appreciated - debugging is getting painful.

gerrit


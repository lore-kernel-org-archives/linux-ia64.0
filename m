From: Steve Tynor <tynor@atlanta.twr.com>
Date: Thu, 05 Oct 2000 14:44:35 +0000
Subject: [Linux-ia64] gcc 0925+patch22 -> as warnings: WAW dependencies
Message-Id: <marc-linux-ia64-105590678205541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm using the 0925 toolchain with gcc version 2.96-ia64-000717 snap
000925 with the patch in the README to allow it to operate on my stock
glibc 2.1.3 Turbolinux install.

My program now seg faults in an as yet to be determined location (leaves
no stack and all registers are "0" according to gdb... joy).  During the
compile, with "gcc -O", I got a number of the following warnings.
Should I be concerned?  Would passing -xauto to "as" help?  I'm not sure
what to make of the warnings; the first one seems to be worried about
the two stores through [r18] (but I don't understand what "resource
number is 45" is trying to tell me).  The second, I'm not sure about
since I don't see any conflifts with r46 or r14 anywhere in the
vicinity.  (though at least in that case "resource is 46" matches the
register in the flagged instruction).


DebugControls.s: Assembler messages:
DebugControls.s:1415: Warning: Use of 'mov' may violate WAW dependency 'GR%, % in 1 - 127' (impliedf) when entry is at label '.L55', specific resource number is 45
DebugControls.s:1415: Warning: Only the first path encountering the conflict is reported
DebugControls.s:1412: Warning: This is the location of the conflicting usage
DebugControls.s:1416: Warning: Use of 'addl' may violate WAW dependency 'GR%, % in 1 - 127' (impliedf) when entry is at label '.L55', specific resource number is 46
DebugControls.s:1416: Warning: Only the first path encountering the conflict is reported
DebugControls.s:1413: Warning: This is the location of the conflicting usage




.L15:
	.loc 0 365 0
	mov r15 = r43
	adds r14 = -8, r43
	mov r16 = r43
	;;
	adds r15 = -232, r43
	mov r17 = r43
	adds r16 = -96, r43
	addl r18 = @ltoff(.LC1), gp
	;;
	ld8 r17 = [r18]
	adds r18 = 16, r12
	;;
	st8 [r18] = r17
	adds r17 = 16, r12
	adds r18 = 24, r12
	;;                           <<<<<<<<<<<<---- line 1412
	addl r17 = 365, r0           <<<<<<<<<<<<---- line 1413
	;;
	st4 [r18] = r17              <<<<<<<<<<<<---- line 1415
	ld8.acq r46 = [r14]          <<<<<<<<<<<<---- line 1416
	ld8 r47 = [r15]
	ld8 r48 = [r16]
	addl r14 = @ltoff(CC_com_twr_Debug#), gp
	;;

Thanks,
Steve


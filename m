From: Jim Wilson <wilson@specifixinc.com>
Date: Tue, 13 Apr 2004 07:17:32 +0000
Subject: proposed gcc/gas -mb-step changes
Message-Id: <1081840653.1046.64.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zack Weinberg of CodeSourcery sent mail to the binutils mailing list
which proposes to add a new -mb-step option to the assembler. 
Currently, gas will always give warnings if given code which triggers an
Itanium (Merced) B-step errata.  The proposal is to only warn when the
new -mb-step option is used.  Also, this means that the existing gcc
option -mb-step will have to pass -mb-step to the assembler.  The
discussion is here
	http://sources.redhat.com/ml/binutils/2004-04/msg00187.html

The linux kernel is the only code I know of that uses the gcc -mb-step
option.  This is used if you configure with B-step support enabled. 
This change means that the kernel should be modified to add -mb-step to
aflags when the B-step support is enabled, just like it currently does
for cflags.  Gas will fail if given a -m option it doesn't recognize, so
this means that these changes will only work with new assembler
versions.  I am assuming that use of the B-step support is rare enough
that this won't be a problem.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com


From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 16 Oct 2003 01:34:41 +0000
Subject: RE: WAW dependency messages
Message-Id: <marc-linux-ia64-106626810627108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106625678318659@msgid-missing>
In-Reply-To: <marc-linux-ia64-106625678318659@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Kernel is a totally different issue. You can send me small asm
> testcases. I will see what I can do.

Something as simple as:

        itc.i r18
        ;;
        ld8 r19=[r17]

Will generate
aa.S: Assembler messages:
aa.S:3: Warning: Use of 'ld8' violates RAW dependency 'DTC' (data)
aa.S:1: Warning: This is the location of the conflicting usage

Oddly enough, "as test.S" doesn't have warning message, but "as -x
test.S" does.  gcc is execve with "as -x" which triggers the warning
message.

- Ken

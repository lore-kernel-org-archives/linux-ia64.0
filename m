From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Fri, 12 Oct 2001 00:19:32 +0000
Subject: [Linux-ia64] Probable seamless bug: can't pop es
Message-Id: <marc-linux-ia64-105590698805337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following simple program runs on a P4 linux system, but gets a SIGSEGV
on an Itanium.  Most likely a seamless bug rather than a hardware bug.  Even
though we don't use segment registers in Linux, it is legal to push and pop
them, isn't it?

main()
{
        asm ("pushl %ds");
        asm ("popl %es");
}

David Robboy


From: Keith Owens <kaos@sgi.com>
Date: Wed, 10 Mar 2004 05:27:07 +0000
Subject: Re: 2.6.3 Heisenbug in unwind.c
Message-Id: <5692.1078896427@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2654.1077624337@ocs3.ocs.com.au>
In-Reply-To: <2654.1077624337@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Feb 2004 23:05:37 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>I am seeing a Heisenbug in the 2.6.3 kernel unwind code.  The symptoms
>are that the backtrace terminates early, usually failing to unwind past
>an interrupt frame.

One possible contender for this unwind Heisenbug.  Building a 2.6.4-rc3
kernel with gcc version 3.2.3 20030502 (Red Hat Linux 3.2.3-24) and GNU
ld version 2.14.90.0.4 20030523.  The unwind data in vmlinux is
invalid, with overlapping entries.  If this command reports anything at
all then your unwind data is stuffed.

readelf -u vmlinux | grep '+[a-f0-9]*>:' | head -5

An extract of the descriptor triplets looks like this.  It seems that
the unwind descriptors for .text and .init.text have been merged
together, as if both sections started at the same offset.

00015a00 00015a70 005ced40
00015a80 00015b20 005ced58 
00015ac0 00015d10 005c6828 Illegal insert, belongs to __init text
00015b20 00015ca0 005ced70
00015ca0 00015d30 005ced90
00015d20 00015e50 005c6848 Illegal insert, belongs to __init text
00015d40 00015f90 005ceda8
00015e60 00015f90 005c6868
00015fa0 000162e0 005c6888

Depending on precisely where the interrupt occurs, you may pick up a
correct or an incorrect unwind descriptor.  Which in turn affects the
backtrace, and explains why changing code size may the Heisenbug move.

Using the same toolchain to build a 2.4 kernel is not a problem.


From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Mar 2002 05:01:01 +0000
Subject: Re: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905252@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Mar 2002 20:45:07 +0000, Richard Hirst <rhirst@linuxcare.com> said:

  Richard> I use parted to create GPT tables, which have a partition
  Richard> type GUID in the first 16 bytes of each table entry.  That
  Richard> entry is being written offset by one byte, so a partition
  Richard> table entry might look like

  Richard> 0000480 00 a2 a0 d0 eb e5 b9 33 44 87 c0 68 b6 b7 26 99
  Richard> 0000490 83 79 f1 c4 f9 32 46 f7 9a 51 cc 85 c5 d8 a9 68
  Richard> 00004a0 00 28 03 00 00 00 00 00 00 40 06 00 00 00 00 00
  Richard> 00004b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

  Richard> instead of

  Richard> 0000480 a2 a0 d0 eb e5 b9 33 44 87 c0 68 b6 b7 26 99 c7
  Richard> 0000490 83 79 f1 c4 f9 32 46 f7 9a 51 cc 85 c5 d8 a9 68
  Richard> 00004a0 00 28 03 00 00 00 00 00 00 40 06 00 00 00 00 00
  Richard> 00004b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

  Richard> I've included the relevant bit of code below, along with a
  Richard> disassembly and a dump of the relevant bit of .rodata.  The
  Richard> significant bit is that
  Richard> "gpt_part_data->pte->PartitionTypeGuid   Richard> PARTITION_BASIC_DATA_GUID" is implemented as a memcpy(),
  Richard> with a source of .rodata+0xe7, while we can see in the dump
  Richard> that the guid is actually at .rodata+0xe8.

  Richard> I've never looked at ia64 asm before today, but I think
  Richard> I've interpreted it correctly.  This is under debian, but
  Richard> the same corruption has been seen under RedHat 7.2.

That is pretty weird.  Does the problem occur with gcc3 as well?  It might
also help to look at the assembly code.

	--david


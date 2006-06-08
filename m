From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Thu, 08 Jun 2006 00:14:22 +0000
Subject: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <3faf05680606071702q690a4a7do5cc5bc6d7e92dbec@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello All,

I found the following segment in all the process's on IA64 linux kernel.

60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 (just
above the stack).

Was wondering what excatly is there in this segment? Does it have any
information about the file descriptors /open file table ?

I have a code which tries to override this segment but once I override
this the program gets corrupted.

Also why IPF kernel differs from other systems where the mmap space is
below &_etext where as on other systems its above &_end. ??

Looking forward to hear from you.
Best,
Vamsi

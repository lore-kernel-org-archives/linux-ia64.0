From: Bill Nottingham <notting@redhat.com>
Date: Mon, 21 Aug 2000 16:13:00 +0000
Subject: Re: [Linux-ia64] 2.4.0-test6 boot problems
Message-Id: <marc-linux-ia64-105590678205360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Pat O'Rourke (orourke@mclinux.com) said: 
> We don't find a partition table because the bread() of it fails.

You need to enable the 4GB support in the Qlogic SCSI BIOS.

Bill


From: Bill Nottingham <notting@redhat.com>
Date: Wed, 08 Jan 2003 21:49:58 +0000
Subject: [Linux-ia64] Re: disabling nics in efi.
Message-Id: <marc-linux-ia64-105590709805645@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roy Dragseth (royd@cc.uit.no) said: 
> The reason for wanting to disable the internal nics is that the redhat 
> installer insists on fetching the kickstart file over eth0 when doing 
> installations over the network and the external nic that I want to use 
> becomes eth2.
> 
> Any hints is greatly appreciated.

linux ksdevice=eth2

Bill


From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 27 Mar 2007 05:15:34 +0000
Subject: Re: sata-vsc broken on SGI Prism
Message-Id: <4608A876.8090104@garzik.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <je8xdnova3.fsf@sykes.suse.de> <20070325012044.97dc14fc.akpm@linux-foundation.org>
In-Reply-To: <20070325012044.97dc14fc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Andreas Schwab <schwab@suse.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Sat, 24 Mar 2007 10:17:24 +0100 Andreas Schwab <schwab@suse.de> wrote:
>> commit 7cbaa86b937b0b1fab95c159989f6a3c00bbcf78
>> Author: Dan Wolstenholme <daniel@wolstenholme.net>
>> Date:   Tue Jan 9 05:59:21 2007 -0500
>>
>>     [libata] sata_vsc: support PCI MSI
>>     
>>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
>>
> 
> It seems that little of that patch remains present in current mainline.


An unfortunately illusion of further changes.  The "turn MSI on" stuff 
is still here, but Tejun's cleanups made some of that housekeeping code 
go away.

But, as Andreas was guessing, the problem here is the platform's MSI 
support, with this as an unfortunate symptom.

	Jeff



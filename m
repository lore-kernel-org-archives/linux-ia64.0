From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 05 Mar 2008 23:38:57 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <21809.1204760337@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson (on Wed, 5 Mar 2008 12:56:29 -0600) wrote:
>On Wed, Mar 05, 2008 at 02:14:52PM +0100, Zoltan Menyhart wrote:
>> Neither the original code, nor mine can log it before the machine
>> is re-booted / halted.
>> Only the recovered ones play.
>> It is safe to continue after the recovered ones.
>> You need these logs to be alerted and to program the maintenance.
>> 
>> Both the original code and mine can "swallow" about 1 recovered
>> event / minute, and tolerate a "burst" of 2 or IA64_MAX_MCA_INIT_BUFS
>> events.
>
>What happens on boot up, when salinfo reads all the old records?
>Does that "burst" of records all get logged.

salinfo on boot up is a serial process, driven from user space.  One
cpu at a time, one record of each type at a time.  Records of different
types are processed in parallel.

   Keith (I wish I had never heard of salinfo) Owens


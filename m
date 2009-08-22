From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 22 Aug 2009 00:06:15 +0000
Subject: Re: [Patch 0/8] V4 Implement crashkernel=auto
Message-Id: <20090821170615.1ea4a4f4.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, nhorman@redhat.com, ebiederm@xmission.com, kamezawa.hiroyu@jp.fujitsu.com, andi@firstfloor.org, amwang@redhat.com, bernhard.walle@gmx.de, fenghua.yu@intel.com, mingo@elte.hu, avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org

(cc linuxppc-dev@ozlabs.org)

On Fri, 21 Aug 2009 02:54:12 -0400
Amerigo Wang <amwang@redhat.com> wrote:

> This series of patch implements automatically reserved memory for crashkernel,
> by introducing a new boot option "crashkernel=auto". This idea is from Neil.
> 
> In case of breaking user-space applications, it modifies this boot option after
> it decides how much memory should be reserved.
> 
> On different arch, the threshold and reserved memory size is different. Please
> refer patch 8/8 which contains an update for the documentation.
> 
> Patch 1/8 implements shrinking reserved memory at run-time, which is useful
> when more than enough memory is reserved automatically.
> 
> Note: This patchset was only tested on x86_64 with differernt memory sizes.


I'd prefer that this change had been runtime tested on ia64 and powerpc
and has had some quality review from relevant developers of those
architectures.

Looking at the cc's, I'm not sure that the powerpc guys even know about
this work?


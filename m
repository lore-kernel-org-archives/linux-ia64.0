From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Aug 2009 22:57:35 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1skg5vpgg.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
In-Reply-To: <20090805140408.GJ7259@hmsreliant.think-freely.org> (Neil Horman's message of "Wed\, 5 Aug 2009 10\:04\:08 -0400")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Neil Horman <nhorman@redhat.com>
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Neil Horman <nhorman@redhat.com> writes:

> On Wed, Aug 05, 2009 at 06:33:57AM -0700, Eric W. Biederman wrote:
>> Amerigo Wang <amwang@redhat.com> writes:
>> 
>> > This series of patch implements automatically reserved memory for crashkernel,
>> > by introducing a new boot option "crashkernel=auto". This idea is from Neil.
>> >
>> > In case of breaking user-space applications, it modifies this boot option after
>> > it decides how much memory should be reserved.
>> >
>> > On different arch, the threshold and reserved memory size is different. Please
>> > refer patch 7/7 which contains an update for the documentation.
>> >
>> > Note: This patchset was only tested on x86_64 with differernt memory sizes.
>> 
>> This seems like a silly hard code. Especially for a feature distros don't
>> care enough about to implement a working initrd for.
>> 
>> Has anyone bothered to justify those large amounts of memory?
>> Where does the 128M go?
>> 
>> Please pardon me for being a cynic but I don't see the command line option
>> being the bottleneck for real users to make this work.
>> 
>> Eric
>
> Lots of the impetus behind this results from a desire to have kexec configured
> and setup up during install.  Having the kernel allocate a default size block of
> RAM lets you do that without the need for an interim reboot.

I assume you mean kexec on panic.  kexec should be fine and you can arguably
solve this problem with a little bit of userspace glue and a kexec of yourself
during bootup.

> You could of
> course boot the installer kernel with a crashkernel line pre-selected  suppose,
> but then you have to go to the trouble of figuring that allocation size out each
> time.  This gives you a nice convienent way to get a reasonable block of memory
> without the need to do all that extra work.

My big concern is that you are moving policy into the kernel, when it isn't at
all clear that policy is the right thing to do, and the existing mechanisms give
you enough rope to do this all in userspace.

You also have to build (or at least load) the whole kdump image after
the system boots, and configure someplace for this to be saved.

What class of problems do you expect to catch with this?

What has me puzzled is that the mkdumprd that ships with fedora isn't
usable without patching, and it seems to be steadily getting worse.  If the
concern was about getting better bug reports I would expect getting this
functionality into fedora would be where you would be focusing your efforts.

Am I missing something obvious?

Eric

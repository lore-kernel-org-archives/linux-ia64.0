From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 11 Aug 2009 20:50:50 +0000
Subject: RE: [RFC Patch 1/2] kexec: show memory info in /proc/iomem
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8B3A855AD@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain>
In-Reply-To: <20090811104144.5154.77871.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Amerigo Wang' <amwang@redhat.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
Cc: "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, 'Neil Horman' <nhorman@redhat.com>, "'Eric W. Biederman'" <ebiederm@xmission.com>, 'Andi Kleen' <andi@firstfloor.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, 'Ingo Molnar' <mingo@elte.hu>

>
>---
>diff --git a/kernel/kexec.c b/kernel/kexec.c
>index f336e21..01673ad 100644
>--- a/kernel/kexec.c
>+++ b/kernel/kexec.c
>@@ -931,6 +931,8 @@ static int kimage_load_segment(struct kimage *image,
>  */
> struct kimage *kexec_image;
> struct kimage *kexec_crash_image;
>+struct resource *kexec_res = NULL;
>+struct resource *kexec_free_res = NULL;
>
> static DEFINE_MUTEX(kexec_mutex);
>
>@@ -939,6 +941,8 @@ SYSCALL_DEFINE4(kexec_load, unsigned long, entry,
>unsigned long, nr_segments,
> {
> 	struct kimage **dest_image, *image;
> 	int result;
>+	unsigned long kexec_start = crashk_res.start;
>+	unsigned long kexec_end = kexec_start;
>
> 	/* We only trust the superuser with rebooting the system. */
> 	if (!capable(CAP_SYS_BOOT))
>@@ -994,6 +998,7 @@ SYSCALL_DEFINE4(kexec_load, unsigned long, entry,
>unsigned long, nr_segments,
> 			kimage_free(xchg(&kexec_crash_image, NULL));
> 			result = kimage_crash_alloc(&image, entry,
> 						     nr_segments, segments);
>+			kexec_end += KEXEC_CONTROL_PAGE_SIZE;
> 		}
> 		if (result)
> 			goto out;
>@@ -1008,6 +1013,42 @@ SYSCALL_DEFINE4(kexec_load, unsigned long, entry,
>unsigned long, nr_segments,
> 			result = kimage_load_segment(image, &image->segment[i]);
> 			if (result)
> 				goto out;
>+			if (flags & KEXEC_ON_CRASH)
>+				kexec_end += image->segment[i].memsz;
>+		}
>+		if (flags & KEXEC_ON_CRASH) {
>+			if (kexec_res) {
>+				release_resource(kexec_res);
>+				release_resource(kexec_free_res);
>+				kfree(kexec_res);
>+				kfree(kexec_free_res);
>+			}
>+			kexec_res = kzalloc(sizeof(*kexec_res), GFP_KERNEL);
>+			if (!kexec_res) {
>+				result = -ENOMEM;
>+				goto out;
>+			}
>+			kexec_free_res = kzalloc(sizeof(*kexec_free_res),
>GFP_KERNEL);
>+			if (!kexec_free_res) {
>+				result = -ENOMEM;
>+				goto out_free;
>+			}
>+			kexec_res->name = "Used";
>+			kexec_res->start = kexec_start;
>+			kexec_res->end = roundup(kexec_end, 1<<20) - 1;
>+			kexec_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
>+			if (insert_resource(&crashk_res, kexec_res)) {
>+				result = -EBUSY;
>+				goto out_free;
>+			}
>+			kexec_free_res->name = "Unused";
>+			kexec_free_res->start = kexec_res->end + 1;
>+			kexec_free_res->end = crashk_res.end;
>+			kexec_free_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
>+			if (insert_resource(&crashk_res, kexec_free_res)) {
>+				result = -EBUSY;
>+				goto out_release;
>+			}
> 		}
> 		kimage_terminate(image);
> 	}
>@@ -1019,6 +1060,13 @@ out:
> 	kimage_free(image);
>
> 	return result;
>+
>+out_free:
>+	kfree(kexec_free_res);
>+	kfree(kexec_res);
>+out_release:
>+	release_resource(kexec_res);
>+	goto out;
> }

The order of out_free: and out_release: might be reversed. You need to release_resource first; then kfree. Otherwise the previous failures jump to here and will cause problem.

Thanks.

-Fenghua

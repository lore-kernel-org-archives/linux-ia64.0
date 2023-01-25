From: Suren Baghdasaryan <surenb@google.com>
Date: Wed, 25 Jan 2023 08:38:49 +0000
Subject: [PATCH v2 4/6] mm: replace vma->vm_flags indirect modification in ksm_madvise
Message-Id: <20230125083851.27759-5-surenb@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230125083851.27759-1-surenb@google.com>
In-Reply-To: <20230125083851.27759-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: michel@lespinasse.org, jglisse@google.com, mhocko@suse.com, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, dave@stgolabs.net, willy@infradead.org, liam.howlett@oracle.com, peterz@infradead.org, ldufour@linux.ibm.com, paulmck@kernel.org, luto@kernel.org, songliubraving@fb.com, peterx@redhat.com, david@redhat.com, dhowells@redhat.com, hughd@google.com, bigeasy@linutronix.de, kent.overstreet@linux.dev, punit.agrawal@bytedance.com, lstoakes@gmail.com, peterjung1337@gmail.com, rientjes@google.com, axelrasmussen@google.com, joelaf@google.com, minchan@google.com, jannh@google.com, shakeelb@google.com, tatashin@google.com, edumazet@google.com, gthelen@google.com, gurua@google.com, arjunroy@google.com, soheil@google.com, hughlynch@google.com, leewalsh@google.com, posk@google.com, will@kernel.org, aneesh.kumar@linux.ibm.com, npiggin@gmail.com, chenhuacai@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, richard@nod.at, anton.ivanov@cambridgegreys.com, johannes@sipsolutions.net, qianweili@huawei.com, wangzhou1@hisilicon.com, herbert@gondor.apana.org.au, davem@davemloft.net, vkoul@kernel.org, airlied@gmail.com, daniel@ffwll.ch, maarten.lankhorst@linux.intel.com, mripard@kernel.org, tzimmermann@suse.de, l.stach@pengutronix.de, krzysztof.kozlowski@linaro.org, patrik.r.jakobsson@gmail.com, matthias.bgg@gmail.com, robdclark@gmail.com, quic_abhinavk@quicinc.com, dmitry.baryshkov@linaro.org, tomba@kernel.org, hjc@rock-chips.com, heiko@sntech.de, ray.huang@amd.com, kraxel@redhat.com, sre@kernel.org, mcoquelin.stm32@gmail.com, alexandre.torgue@foss.st.com, tfiga@chromium.org, m.szyprowski@samsung.com, mchehab@kernel.org, dimitri.sivanich@hpe.com, zhangfei.gao@linaro.org, jejb@linux.ibm.com, martin.petersen@oracle.com, dgilbert@interlog.com, hdegoede@redhat.com, mst@redhat.com, jasowang@redhat.com, alex.williamson@redhat.com, deller@gmx.de, jayalk@intworks.biz, viro@zeniv.linux.org.uk, nico@fluxnic.net, xiang@kernel.org, chao@kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, miklos@szeredi.hu, mike.kravetz@oracle.com, muchun.song@linux.dev, bhe@redhat.com, andrii@kernel.org, yoshfuji@linux-ipv6.org, dsahern@kernel.org, kuba@kernel.org, pabeni@redhat.com, perex@perex.cz, tiwai@suse.com, haojian.zhuang@gmail.com, robert.jarzmik@free.fr, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-graphics-maintainer@vmware.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, loongarch@lists.linux.dev, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-sgx@vger.kernel.org, linux-um@lists.infradead.org, linux-acpi@vger.kernel.org, linux-crypto@vger.kernel.org, nvdimm@lists.linux.dev, dmaengine@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, etnaviv@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mediatek@lists.infradead.org, linux-arm-msm@vger.kernel.org, freedreno@lists.freedesktop.org, linux-rockchip@lists.infradead.org, linux-tegra@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-stm32@st-md-mailman.stormreply.com, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-accelerators@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org, linux-staging@lists.linux.dev, target-devel@vger.kernel.org, linux-usb@vger.kernel.org, netdev@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-ext4@vger.kernel.org, devel@lists.orangefs.org, kexec@lists.infradead.org, linux-xfs@vger.kernel.org, bpf@vger.kernel.org, linux-perf-users@vger.kernel.org, kasan-dev@googlegroups.com, selinux@vger.kernel.org, alsa-devel@alsa-project.org, kernel-team@android.com, surenb@google.com

Replace indirect modifications to vma->vm_flags with calls to modifier
functions to be able to track flag changes and to keep vma locking
correctness. Add a BUG_ON check in ksm_madvise() to catch indirect
vm_flags modification attempts.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 arch/powerpc/kvm/book3s_hv_uvmem.c | 5 ++++-
 arch/s390/mm/gmap.c                | 5 ++++-
 mm/khugepaged.c                    | 2 ++
 mm/ksm.c                           | 2 ++
 4 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_uvmem.c b/arch/powerpc/kvm/book3s_hv_uvmem.c
index 1d67baa5557a..325a7a47d348 100644
--- a/arch/powerpc/kvm/book3s_hv_uvmem.c
+++ b/arch/powerpc/kvm/book3s_hv_uvmem.c
@@ -393,6 +393,7 @@ static int kvmppc_memslot_page_merge(struct kvm *kvm,
 {
 	unsigned long gfn = memslot->base_gfn;
 	unsigned long end, start = gfn_to_hva(kvm, gfn);
+	unsigned long vm_flags;
 	int ret = 0;
 	struct vm_area_struct *vma;
 	int merge_flag = (merge) ? MADV_MERGEABLE : MADV_UNMERGEABLE;
@@ -409,12 +410,14 @@ static int kvmppc_memslot_page_merge(struct kvm *kvm,
 			ret = H_STATE;
 			break;
 		}
+		vm_flags = vma->vm_flags;
 		ret = ksm_madvise(vma, vma->vm_start, vma->vm_end,
-			  merge_flag, &vma->vm_flags);
+			  merge_flag, &vm_flags);
 		if (ret) {
 			ret = H_STATE;
 			break;
 		}
+		reset_vm_flags(vma, vm_flags);
 		start = vma->vm_end;
 	} while (end > vma->vm_end);
 
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index 3a695b8a1e3c..d5eb47dcdacb 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -2587,14 +2587,17 @@ int gmap_mark_unmergeable(void)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	unsigned long vm_flags;
 	int ret;
 	VMA_ITERATOR(vmi, mm, 0);
 
 	for_each_vma(vmi, vma) {
+		vm_flags = vma->vm_flags;
 		ret = ksm_madvise(vma, vma->vm_start, vma->vm_end,
-				  MADV_UNMERGEABLE, &vma->vm_flags);
+				  MADV_UNMERGEABLE, &vm_flags);
 		if (ret)
 			return ret;
+		reset_vm_flags(vma, vm_flags);
 	}
 	mm->def_flags &= ~VM_MERGEABLE;
 	return 0;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 8abc59345bf2..76b24cd0c179 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -354,6 +354,8 @@ struct attribute_group khugepaged_attr_group = {
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
 {
+	/* vma->vm_flags can be changed only using modifier functions */
+	BUG_ON(vm_flags = &vma->vm_flags);
 	switch (advice) {
 	case MADV_HUGEPAGE:
 #ifdef CONFIG_S390
diff --git a/mm/ksm.c b/mm/ksm.c
index 04f1c8c2df11..992b2be9f5e6 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2573,6 +2573,8 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
+	/* vma->vm_flags can be changed only using modifier functions */
+	BUG_ON(vm_flags = &vma->vm_flags);
 	switch (advice) {
 	case MADV_MERGEABLE:
 		/*
-- 
2.39.1

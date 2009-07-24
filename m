From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 24 Jul 2009 17:40:25 +0000
Subject: Re: [PATCH] ia64/topology.c: exit cache_add_dev when kobject_init_and_add fails
Message-Id: <20090724174025.GA6568@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1248427228-30901-1-git-send-email-dfeng@redhat.com>
In-Reply-To: <1248427228-30901-1-git-send-email-dfeng@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xiaotian Feng <dfeng@redhat.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 24, 2009 at 02:20:28AM -0700, Xiaotian Feng wrote:
> make cache_add_dev exit sysfs when kobject_init_and_add returns an
> error.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> ---
>  arch/ia64/kernel/topology.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
> index bc80dff..82c5a8f 100644
> --- a/arch/ia64/kernel/topology.c
> +++ b/arch/ia64/kernel/topology.c
> @@ -372,6 +372,10 @@ static int __cpuinit cache_add_dev(struct sys_device * sys_dev)
>         retval = kobject_init_and_add(&all_cpu_cache_info[cpu].kobj,
>                                       &cache_ktype_percpu_entry, &sys_dev->kobj,
>                                       "%s", "cache");
> +       if (retval < 0) {
> +               cpu_cache_sysfs_exit(cpu);
> +               return retval;
> +       }
> 
>         for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++) {
>                 this_object = LEAF_KOBJECT_PTR(cpu,i);

I add another related failure handling change on top of your patch. Without the
change, kobject_uevent(&all_cpu_cache_info[cpu].kobj, KOBJ_ADD) is still
executed even when previous kobject_init_adn_add failure.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---
 arch/ia64/kernel/topology.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index bc80dff..8f06035 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -372,6 +372,10 @@ static int __cpuinit cache_add_dev(struct sys_device * sys_dev)
 	retval = kobject_init_and_add(&all_cpu_cache_info[cpu].kobj,
 				      &cache_ktype_percpu_entry, &sys_dev->kobj,
 				      "%s", "cache");
+	if (unlikely(retval < 0)) {
+		cpu_cache_sysfs_exit(cpu);
+		return retval;
+	}
 
 	for (i = 0; i < all_cpu_cache_info[cpu].num_cache_leaves; i++) {
 		this_object = LEAF_KOBJECT_PTR(cpu,i);
@@ -385,7 +389,7 @@ static int __cpuinit cache_add_dev(struct sys_device * sys_dev)
 			}
 			kobject_put(&all_cpu_cache_info[cpu].kobj);
 			cpu_cache_sysfs_exit(cpu);
-			break;
+			return retval;
 		}
 		kobject_uevent(&(this_object->kobj), KOBJ_ADD);
 	}

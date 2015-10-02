From: Ashwin Chaugule <ashwin.chaugule@linaro.org>
Date: Fri, 02 Oct 2015 17:07:18 +0000
Subject: Re: [PATCH v2 5/5] ACPI / processor_idle: Add support for Low Power Idle(LPI) states
Message-Id: <CAJ5Y-eaY9vQ=yhy649Nyj_rrTRubCUG_VG3rpNHM-LDv4jJkPA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
 <1442411963-14398-1-git-send-email-sudeep.holla@arm.com> <1442411963-14398-6-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1442411963-14398-6-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux acpi <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>

Hi Sudeep,

On 16 September 2015 at 09:59, Sudeep Holla <sudeep.holla@arm.com> wrote:
> ACPI 6.0 introduced an optional object _LPI that provides an alternate
> method to describe Low Power Idle states. It defines the local power
> states for each node in a hierarchical processor topology. The OSPM can
> use _LPI object to select a local power state for each level of processor
> hierarchy in the system. They used to produce a composite power state
> request that is presented to the platform by the OSPM.
>
> Since multiple processors affect the idle state for any non-leaf hierarchy
> node, coordination of idle state requests between the processors is
> required. ACPI supports two different coordination schemes: Platform
> coordinated and  OS initiated.
>
> This patch adds initial support for Platform coordination scheme of LPI.
>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
> ---
>  drivers/acpi/Kconfig            |   3 +
>  drivers/acpi/bus.c              |   8 +-
>  drivers/acpi/processor_driver.c |   2 +-
>  drivers/acpi/processor_idle.c   | 412 +++++++++++++++++++++++++++++++++++-----
>  include/acpi/processor.h        |  26 ++-
>  include/linux/acpi.h            |   4 +
>  6 files changed, 405 insertions(+), 50 deletions(-)
>
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 1eb0b8a84a65..1bb6fade84bc 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -51,6 +51,9 @@ config ARCH_MIGHT_HAVE_ACPI_PDC
>  config ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
>         bool
>
> +config ARCH_SUPPORTS_ACPI_PROCESSOR_LPI
> +       bool
> +
>  config ACPI_GENERIC_GSI
>         bool
>
> diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
> index a212cefae524..2e9e2e3fde6a 100644
> --- a/drivers/acpi/bus.c
> +++ b/drivers/acpi/bus.c
> @@ -301,6 +301,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct acpi_osc_context *context)
>  EXPORT_SYMBOL(acpi_run_osc);
>
>  bool osc_sb_apei_support_acked;
> +bool osc_pc_lpi_support_acked;
>  static u8 sb_uuid_str[] = "0811B06E-4A27-44F9-8D60-3CBBC22E7B48";
>  static void acpi_bus_osc_support(void)
>  {
> @@ -321,6 +322,8 @@ static void acpi_bus_osc_support(void)
>                 capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_PPC_OST_SUPPORT;
>
>         capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_HOTPLUG_OST_SUPPORT;
> +       if (IS_ENABLED(CONFIG_ARCH_SUPPORTS_ACPI_PROCESSOR_LPI))
> +               capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_PCLPI_SUPPORT;
>
>         if (!ghes_disable)
>                 capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_APEI_SUPPORT;
> @@ -328,9 +331,12 @@ static void acpi_bus_osc_support(void)
>                 return;
>         if (ACPI_SUCCESS(acpi_run_osc(handle, &context))) {
>                 u32 *capbuf_ret = context.ret.pointer;
> -               if (context.ret.length > OSC_SUPPORT_DWORD)
> +               if (context.ret.length > OSC_SUPPORT_DWORD) {
>                         osc_sb_apei_support_acked >                                 capbuf_ret[OSC_SUPPORT_DWORD] & OSC_SB_APEI_SUPPORT;
> +                       osc_pc_lpi_support_acked > +                               capbuf_ret[OSC_SUPPORT_DWORD] & OSC_SB_PCLPI_SUPPORT;
> +               }

Not sure we want to keep adding more OSC global flags, since theyre
not really used elsewhere outside the drivers. I'm not strongly
against it, but seems like for LPI, CPPC and maybe a few others, we
could do the check locally, like pcc-cpufreq does.

>                 kfree(context.ret.pointer);
>         }
>         /* do we need to check other returned cap? Sounds no */
> diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
> index dff584a7137b..5000f4af1d5e 100644
> --- a/drivers/acpi/processor_driver.c
> +++ b/drivers/acpi/processor_driver.c
> @@ -90,7 +90,7 @@ static void acpi_processor_notify(acpi_handle handle, u32 event, void *data)
>                                                   pr->performance_platform_limit);
>                 break;
>         case ACPI_PROCESSOR_NOTIFY_POWER:
> -               acpi_processor_cst_has_changed(pr);
> +               acpi_processor_power_state_has_changed(pr);
>                 acpi_bus_generate_netlink_event(device->pnp.device_class,
>                                                   dev_name(&device->dev), event, 0);
>                 break;
> diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
> index 9ca840c88f48..af851f16bb2e 100644
> --- a/drivers/acpi/processor_idle.c
> +++ b/drivers/acpi/processor_idle.c
> @@ -576,7 +576,7 @@ static int acpi_processor_power_verify(struct acpi_processor *pr)
>         return (working);
>  }
>
> -static int acpi_processor_get_power_info(struct acpi_processor *pr)
> +static int acpi_processor_get_cstate_info(struct acpi_processor *pr)
>  {
>         unsigned int i;
>         int result;
> @@ -810,31 +810,12 @@ static void acpi_idle_enter_freeze(struct cpuidle_device *dev,
>         acpi_idle_do_entry(cx);
>  }
>
> -/**
> - * acpi_processor_setup_cpuidle_cx - prepares and configures CPUIDLE
> - * device i.e. per-cpu data
> - *
> - * @pr: the ACPI processor
> - * @dev : the cpuidle device
> - */
>  static int acpi_processor_setup_cpuidle_cx(struct acpi_processor *pr,
>                                            struct cpuidle_device *dev)
>  {
>         int i, count = CPUIDLE_DRIVER_STATE_START;
>         struct acpi_processor_cx *cx;
>
> -       if (!pr->flags.power_setup_done)
> -               return -EINVAL;
> -
> -       if (pr->flags.power = 0) {
> -               return -EINVAL;
> -       }
> -
> -       if (!dev)
> -               return -EINVAL;
> -
> -       dev->cpu = pr->id;
> -
>         if (max_cstate = 0)
>                 max_cstate = 1;
>
> @@ -857,31 +838,13 @@ static int acpi_processor_setup_cpuidle_cx(struct acpi_processor *pr,
>         return 0;
>  }
>
> -/**
> - * acpi_processor_setup_cpuidle states- prepares and configures cpuidle
> - * global state data i.e. idle routines
> - *
> - * @pr: the ACPI processor
> - */
> -static int acpi_processor_setup_cpuidle_states(struct acpi_processor *pr)
> +static int acpi_processor_setup_cstates(struct acpi_processor *pr)
>  {
>         int i, count = CPUIDLE_DRIVER_STATE_START;
>         struct acpi_processor_cx *cx;
>         struct cpuidle_state *state;
>         struct cpuidle_driver *drv = &acpi_idle_driver;
>
> -       if (!pr->flags.power_setup_done)
> -               return -EINVAL;
> -
> -       if (pr->flags.power = 0)
> -               return -EINVAL;
> -
> -       drv->safe_state_index = -1;
> -       for (i = CPUIDLE_DRIVER_STATE_START; i < CPUIDLE_STATE_MAX; i++) {
> -               drv->states[i].name[0] = '\0';
> -               drv->states[i].desc[0] = '\0';
> -       }
> -
>         if (max_cstate = 0)
>                 max_cstate = 1;
>
> @@ -943,24 +906,381 @@ static inline void acpi_processor_cstate_first_run_checks(void)
>
>  static inline int disabled_by_idle_boot_param(void) { return 0; }
>  static inline void acpi_processor_cstate_first_run_checks(void) { }
> -static int acpi_processor_get_power_info(struct acpi_processor *pr)
> +static int acpi_processor_get_cstate_info(struct acpi_processor *pr)
>  {
>         return -ENODEV;
>  }
> -
>  static int acpi_processor_setup_cpuidle_cx(struct acpi_processor *pr,
>                                            struct cpuidle_device *dev)
>  {
>         return -EINVAL;
>  }
>
> -static int acpi_processor_setup_cpuidle_states(struct acpi_processor *pr)
> +static int acpi_processor_setup_cstates(struct acpi_processor *pr)
> +{
> +       return -EINVAL;
> +}
> +#endif
> +
> +#ifdef CONFIG_ARCH_SUPPORTS_ACPI_PROCESSOR_LPI
> +
> +struct acpi_processor_lpi_info {
> +       int state_count;
> +       struct acpi_processor_lpi *lpix;
> +};
> +
> +static int acpi_processor_evaluate_lpi(acpi_handle handle,
> +                                      struct acpi_processor_lpi_info *info)
> +{
> +       acpi_status status = 0;
> +       int ret;
> +       int version, level, pkg_count, state_count = 1, loop;
> +       struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
> +       union acpi_object *lpi;
> +       struct acpi_processor_lpi *lpix;
> +
> +       status = acpi_evaluate_object(handle, "_LPI", NULL, &buffer);
> +       if (ACPI_FAILURE(status)) {
> +               ACPI_DEBUG_PRINT((ACPI_DB_INFO, "No _LPI, giving up\n"));
> +               return -ENODEV;
> +       }
> +
> +       lpi = buffer.pointer;
> +
> +       /* There must be at least 4 elements = 3 elements + 1 package */
> +       if (!lpi || (lpi->type != ACPI_TYPE_PACKAGE) || lpi->package.count < 4) {
> +               pr_info("not enough elements in _LPI\n");
> +               ret = -EFAULT;
> +               goto end;
> +       }
> +
> +       version = lpi->package.elements[0].integer.value;
> +       level = lpi->package.elements[1].integer.value;
> +       pkg_count = lpi->package.elements[2].integer.value;
> +
> +       /* Validate number of power states. */
> +       if (pkg_count < 1 || pkg_count != lpi->package.count - 3) {
> +               pr_err("count given by _LPI is not valid\n");
> +               ret = -EFAULT;
> +               goto end;
> +       }
> +
> +       lpix = kcalloc(pkg_count, sizeof(*lpix), GFP_KERNEL);
> +       if (!lpix) {
> +               ret = -ENOMEM;
> +               goto end;
> +       }
> +
> +       info->state_count = pkg_count;
> +       info->lpix = lpix;
> +       for (loop = 3; state_count <= pkg_count; loop++, state_count++, lpix++) {

Reusing state_count can be confusing. Maybe use state_idx, state_ctr
or something. Or add comments to explain how this thing is laid out.

> +               union acpi_object *element, *obj;
> +
> +               element = &lpi->package.elements[loop];
> +               if (element->type != ACPI_TYPE_PACKAGE)
> +                       continue;
> +
> +               if (element->package.count < 7)
> +                       continue;
> +
> +               /* TODO
> +                * this long list is looking insane now
> +                * need a cleaner and saner way to read the elements
> +                */
> +               obj = &element->package.elements[6];
> +               if (obj->type = ACPI_TYPE_BUFFER) {
> +                       struct acpi_power_register *reg;
> +
> +                       reg = (struct acpi_power_register *)obj->buffer.pointer;
> +                       if (reg->space_id != ACPI_ADR_SPACE_SYSTEM_IO &&
> +                           (reg->space_id != ACPI_ADR_SPACE_FIXED_HARDWARE))
> +                               continue;
> +                       lpix->address = reg->address;
> +                       if (reg->space_id = ACPI_ADR_SPACE_FIXED_HARDWARE)
> +                               lpix->entry_method = ACPI_CSTATE_FFH;
> +                       else
> +                               lpix->entry_method = ACPI_CSTATE_SYSTEMIO;
> +               } else if (obj->type = ACPI_TYPE_INTEGER)
> +                       lpix->address = obj->integer.value;
> +               else
> +                       continue;
> +
> +               /* elements[7,8] skipped for now i.e. Residency/Usage counter*/
> +
> +               obj = &element->package.elements[9];
> +               if (obj->type = ACPI_TYPE_STRING)
> +                       strncpy(lpix->desc, obj->string.pointer, ACPI_CX_DESC_LEN);
> +
> +               lpix->index = state_count;
> +
> +               obj = &element->package.elements[0];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->min_residency = obj->integer.value;
> +
> +               obj = &element->package.elements[1];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->wake_latency = obj->integer.value;
> +
> +               obj = &element->package.elements[2];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->flags = obj->integer.value;
> +
> +               obj = &element->package.elements[3];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->arch_flags = obj->integer.value;
> +
> +               obj = &element->package.elements[4];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->res_cnt_freq = obj->integer.value;
> +
> +               obj = &element->package.elements[5];
> +               if (obj->type != ACPI_TYPE_INTEGER)
> +                       continue;
> +               lpix->enable_parent_state = obj->integer.value;
> +       }
> +       ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Found %d power states\n",
> +                         state_count));
> +end:
> +       kfree(buffer.pointer);
> +       return status;
> +}
> +
> +static int max_leaf_depth, fl_scnt;
> +/*
> + * l_lpi - local LPI state
> + * p_lpi - parent LPI state
> + * c_lpi - composite LPI state
> + */
> +static void combine_lpi_states(struct acpi_processor_lpi *l_lpi,
> +                              struct acpi_processor_lpi *p_lpi,
> +                              struct acpi_processor_lpi *c_lpi)
> +{
> +       c_lpi->min_residency = max(l_lpi->min_residency, p_lpi->min_residency);
> +       c_lpi->wake_latency = l_lpi->wake_latency + p_lpi->wake_latency;
> +       c_lpi->enable_parent_state = p_lpi->enable_parent_state;
> +       c_lpi->entry_method = l_lpi->entry_method;
> +       c_lpi->address = l_lpi->address + p_lpi->address;

Aren't there some constraints to how this addr is worked out? Need to
look at the LPI spec. but IIRC, in some cases its not additive and the
parent value is used for overwriting.

> +       c_lpi->index = p_lpi->index;
> +       c_lpi->flags = p_lpi->flags;
> +       c_lpi->arch_flags = p_lpi->arch_flags;
> +       strncpy(c_lpi->desc, l_lpi->desc, ACPI_CX_DESC_LEN);
> +       strncat(c_lpi->desc, "+", ACPI_CX_DESC_LEN);
> +       strncat(c_lpi->desc, p_lpi->desc, ACPI_CX_DESC_LEN);
> +}
> +
> +static int flatten_lpi_states(struct acpi_processor *pr,
> +                             struct acpi_processor_lpi_info *info,
> +                             struct acpi_processor_lpi *lpi,
> +                             uint32_t depth)
> +{
> +       int j, scount = info[depth].state_count;
> +       struct acpi_processor_lpi *t = info[depth].lpix;
> +
> +       for (j = 0; j < scount; j++, t++) {
> +               struct acpi_processor_lpi *flpi = &pr->power.lpi_states[fl_scnt];
> +               bool valid = false;
> +
> +               if (depth = max_leaf_depth) { /* leaf/processor node */
> +                       memcpy(flpi, t, sizeof(*t));
> +                       fl_scnt++;
> +                       valid = true;
> +               } else if (lpi && t->index <= lpi->enable_parent_state) {
> +                       combine_lpi_states(lpi, t, flpi);
> +                       fl_scnt++;
> +                       valid = true;
> +               }
> +               if (valid && depth)
> +                       flatten_lpi_states(pr, info, flpi, depth - 1);
> +       }
> +       return 0;
> +}

So is this thing taking one idle state at a time from each node
(proc/cluster..) and checking if it can be collapsed with one state
from each parent node (using the EPS constraint) then moving to the
next idle state at the lower node and up again?

> +
> +static int acpi_processor_get_lpi_info(struct acpi_processor *pr)
> +{
> +       int ret, i;
> +       struct acpi_processor_lpi_info *info;
> +       struct acpi_device *d = NULL;
> +       acpi_handle handle = pr->handle, phandle;
> +       acpi_status status;
> +
> +       if (!osc_pc_lpi_support_acked)
> +               return -EOPNOTSUPP;
> +
> +       max_leaf_depth = 0;
> +       if (!acpi_has_method(handle, "_LPI"))
> +               return -EINVAL;
> +       fl_scnt = 0;
> +
> +       while (ACPI_SUCCESS(status = acpi_get_parent(handle, &phandle))) {
> +               if (!acpi_has_method(handle, "_LPI"))
> +                       continue;
> +               acpi_bus_get_device(handle, &d);
> +               if (!strcmp(acpi_device_hid(d), ACPI_PROCESSOR_CONTAINER_HID))
> +                       break;
> +               max_leaf_depth++;
> +               handle = phandle;
> +       }
> +
> +       info = kcalloc(max_leaf_depth + 1, sizeof(*info), GFP_KERNEL);
> +       if (!info)
> +               return -ENOMEM;
> +
> +       phandle = pr->handle;
> +       for (i = max_leaf_depth; i >= 0 && ACPI_SUCCESS(status); i--) {
> +               handle = phandle;
> +               ret = acpi_processor_evaluate_lpi(handle, info + i);
> +               if (ret)
> +                       break;
> +               status = acpi_get_parent(handle, &phandle);
> +       }
> +
> +       flatten_lpi_states(pr, info, NULL, max_leaf_depth);
> +
> +       pr->power.count = fl_scnt;
> +       for (i = 0; i <= max_leaf_depth; i++)
> +               kfree(info[i].lpix);
> +       kfree(info);
> +
> +       /* Tell driver that _LPI is supported. */
> +       pr->flags.has_lpi = 1;
> +       pr->flags.power = 1;
> +
> +       return 0;
> +}
> +
> +/**
> + * acpi_idle_lpi_enter - enters an ACPI any LPI state
> + * @dev: the target CPU
> + * @drv: cpuidle driver containing cpuidle state info
> + * @index: index of target state
> + *
> + */

Might as well add Return types to the kernel doc. here and elsewhere.

> +static int acpi_idle_lpi_enter(struct cpuidle_device *dev,
> +                              struct cpuidle_driver *drv, int index)
>  {
> +       struct acpi_processor *pr;
> +       struct acpi_processor_lpi *lpi;
> +
> +       pr = __this_cpu_read(processors);
> +
> +       if (unlikely(!pr))
> +               return -EINVAL;
> +
> +       lpi = &pr->power.lpi_states[index];
> +       if (lpi->entry_method = ACPI_CSTATE_FFH)
> +               /* Call into architectural FFH based C-state */
> +               return acpi_processor_ffh_lpi_enter(lpi, index);

Where is this thing (and the lpi_probe()) defined ?

>         return -EINVAL;
>  }
>
> +static int acpi_processor_setup_lpi_states(struct acpi_processor *pr)
> +{
> +       int i;
> +       struct acpi_processor_lpi *lpi;
> +       struct cpuidle_state *state;
> +       struct cpuidle_driver *drv = &acpi_idle_driver;
> +
> +       for (i = 0; i < fl_scnt && i < CPUIDLE_STATE_MAX; i++) {
> +               lpi = &pr->power.lpi_states[i];
> +
> +               state = &drv->states[i];
> +               snprintf(state->name, CPUIDLE_NAME_LEN, "LPI-%d", i);
> +               strncpy(state->desc, lpi->desc, CPUIDLE_DESC_LEN);
> +               state->exit_latency = lpi->wake_latency;
> +               state->target_residency = lpi->min_residency;
> +               if (lpi->arch_flags)
> +                       state->flags |= CPUIDLE_FLAG_TIMER_STOP;

Plan to add arch specific callbacks later? FFH spec has some details
for ARM64 on what to save/restore.

Regards,
Ashwin

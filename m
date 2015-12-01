From: "Prakash, Prashanth" <pprakash@codeaurora.org>
Date: Tue, 01 Dec 2015 17:23:50 +0000
Subject: Re: [PATCH v2 5/5] ACPI / processor_idle: Add support for Low Power Idle(LPI) states
Message-Id: <565DD7A6.1000802@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
 <1442411963-14398-1-git-send-email-sudeep.holla@arm.com>
 <1442411963-14398-6-git-send-email-sudeep.holla@arm.com>
 <CAJ5Y-ebOPE1oamRk31nxL6VkgSdDd6AmEe2Fw1ku5pGt25D2Rg@mail.gmail.com>
In-Reply-To: <CAJ5Y-ebOPE1oamRk31nxL6VkgSdDd6AmEe2Fw1ku5pGt25D2Rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ashwin Chaugule <ashwin.chaugule@linaro.org>, Sudeep Holla <sudeep.holla@arm.com>
Cc: linux acpi <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, wufan@codeaurora.org

Hi Sudeep,
>> +static void combine_lpi_states(struct acpi_processor_lpi *l_lpi,
>> +                              struct acpi_processor_lpi *p_lpi,
>> +                              struct acpi_processor_lpi *c_lpi)
>> +{
>> +       c_lpi->min_residency = max(l_lpi->min_residency, p_lpi->min_residency);
>> +       c_lpi->wake_latency = l_lpi->wake_latency + p_lpi->wake_latency;
>> +       c_lpi->enable_parent_state = p_lpi->enable_parent_state;
>> +       c_lpi->entry_method = l_lpi->entry_method;
>> +       c_lpi->address = l_lpi->address + p_lpi->address;
>> +       c_lpi->index = p_lpi->index;
>> +       c_lpi->flags = p_lpi->flags;
>> +       c_lpi->arch_flags = p_lpi->arch_flags;
>> +       strncpy(c_lpi->desc, l_lpi->desc, ACPI_CX_DESC_LEN);
>> +       strncat(c_lpi->desc, "+", ACPI_CX_DESC_LEN);
>> +       strncat(c_lpi->desc, p_lpi->desc, ACPI_CX_DESC_LEN);
>> +}
I suppose you meant to use strl* instead of strn* operations.  Below is a
simple patch to fix these. Can you please fold these changes into your next
version as well?

ACPI / Processor: fix buffer overflow caused by strncat/strncpy

The misuse of strncat in LPI code is causing buffer overflow. The fix
is to replace strncat with strlcat.

Signed-off-by: Fan Wu <wufan@codeaurora.org>
Signed-off-by: Prashanth Prakash <pprakash@codeaurora.org>
---

 drivers/acpi/processor_idle.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index af851f1..4ca42a7 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -856,7 +856,7 @@ static int acpi_processor_setup_cstates(struct acpi_processor *pr)
 
 		state = &drv->states[count];
 		snprintf(state->name, CPUIDLE_NAME_LEN, "C%d", i);
-		strncpy(state->desc, cx->desc, CPUIDLE_DESC_LEN);
+		strlcpy(state->desc, cx->desc, CPUIDLE_DESC_LEN);
 		state->exit_latency = cx->latency;
 		state->target_residency = cx->latency * latency_factor;
 		state->enter = acpi_idle_enter;
@@ -1009,7 +1009,7 @@ static int acpi_processor_evaluate_lpi(acpi_handle handle,
 
 		obj = &element->package.elements[9];
 		if (obj->type = ACPI_TYPE_STRING)
-			strncpy(lpix->desc, obj->string.pointer, ACPI_CX_DESC_LEN);
+			strlcpy(lpix->desc, obj->string.pointer, ACPI_CX_DESC_LEN);
 
 		lpix->index = state_count;
 
@@ -1068,9 +1068,9 @@ static void combine_lpi_states(struct acpi_processor_lpi *l_lpi,
 	c_lpi->index = p_lpi->index;
 	c_lpi->flags = p_lpi->flags;
 	c_lpi->arch_flags = p_lpi->arch_flags;
-	strncpy(c_lpi->desc, l_lpi->desc, ACPI_CX_DESC_LEN);
-	strncat(c_lpi->desc, "+", ACPI_CX_DESC_LEN);
-	strncat(c_lpi->desc, p_lpi->desc, ACPI_CX_DESC_LEN);
+	strlcpy(c_lpi->desc, l_lpi->desc, ACPI_CX_DESC_LEN);
+	strlcat(c_lpi->desc, "+", ACPI_CX_DESC_LEN);
+	strlcat(c_lpi->desc, p_lpi->desc, ACPI_CX_DESC_LEN);
 }
 
 static int flatten_lpi_states(struct acpi_processor *pr,
@@ -1190,7 +1190,7 @@ static int acpi_processor_setup_lpi_states(struct acpi_processor *pr)
 
 		state = &drv->states[i];
 		snprintf(state->name, CPUIDLE_NAME_LEN, "LPI-%d", i);
-		strncpy(state->desc, lpi->desc, CPUIDLE_DESC_LEN);
+		strlcpy(state->desc, lpi->desc, CPUIDLE_DESC_LEN);
 		state->exit_latency = lpi->wake_latency;
 		state->target_residency = lpi->min_residency;
 		if (lpi->arch_flags)
-- 
1.8.2.1



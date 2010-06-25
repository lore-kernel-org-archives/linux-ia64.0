From: "bob_zhang2004" <bob_zhang2004@tom.com>
Date: Fri, 25 Jun 2010 14:11:52 +0000
Subject: Re: Re: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11 ia64)power off failrue when "shut
Message-Id: <201006252211514433897@tom.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201006242333018701088@tom.com>,
 <AANLkTinT8YMKGw3obdbIMINkUGNUgfUQEOEzgHMOPOtt@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, "len.brown" <len.brown@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

 Hi all, 

	I found a amazing problem when debugging this issue. 
As ACPI spec4.0a , if we want to make the system into S5 (soft-off ) status, what we should do is like this:

	P85:
	The logic is controlled via two bit fields: Sleep Enable (SLP_EN) and Sleep Type (SLP_TYPx). The type
	of sleep state desired is programmed into the SLP_TYPx field and upon assertion of the SLP_EN the
	hardware will sequence the system into the defined sleeping state. OSPM gets values for the SLP_TYPx
	field from the \_Sx objects defined in the static definition block. If the object is missing OSPM assumes the
	hardware does not support that sleeping state. Prior to entering the desired sleeping state, OSPM will read
	the designated \_Sx object and place this value in the SLP_TYP field.

One word , we should write a value to register SLP_TYP, afterwards , set SLP_EN bit,  hardware will sequence the system into the defined sleeping state (for example S5).
From this sentence " Each sleeping object contains two constant 3-bit values that OSPM will program into the SLP_TYPa and SLP_TYPb fields (in fixed register space)."
We can simply get a conclusion : The value written to SLP_TYP should be different between S0~S5 ,moreover , this value is gotten from firmware , not controlled by us.
But  in debugging information, I can see that for S0~S5 , they have the same value by converting ,and then written to SLP_TYP. (see "acpi_enter_sleep_state() ").

My debugging code:
acpi_status acpi_enter_sleep_state_prep(u8 sleep_state) {
	acpi_status status;
	struct acpi_object_list arg_list;
	union acpi_object arg;

	ACPI_FUNCTION_TRACE(acpi_enter_sleep_state_prep);

	//added by Bob for checking all type_a and type_b values for different State(S0~S5), should be different.
	{
		int i=0;
		u8 bobtype_a;
		u8 bobtype_b;

		for(i=0;i<6;i++) {
			acpi_get_sleep_type_data(sleep_state, &bobtype_a, &bobtype_b);
			printk("for S[%d] status , type_a=%d, type_b=%d\n",sleep_state,bobtype_a,bobtype_b);
		}
	} //over.
	

	//this code is from kernel. Kernel (OSPM) will get this value from firmware ,and by somewhat converting, and then write it into SLP_TYP .
	/*
	 * _PSW methods could be run here to enable wake-on keyboard, LAN, etc.
	 */
	status = acpi_get_sleep_type_data(sleep_state,
					  &acpi_gbl_sleep_type_a,
					  &acpi_gbl_sleep_type_b);
	if (ACPI_FAILURE(status)) {
		return_ACPI_STATUS(status);
	}


Following is partial output information:
We can see that, for S0~S4 ,they all have {128,7) , it apparently is wrong as ACPI 4.0a SPEC.
For S5 , it is {7,7}. 

only test type value 
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0150 [E000000185900000] [02] get_sleep_type_data   : AE_NOT_FOUND while evaluating SleepState [\_S0_]
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- ****Exception****: AE_NOT_FOUND
for state S[0] , typea8 , typeb=7
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0150 [E000000185900000] [02] get_sleep_type_data   : AE_NOT_FOUND while evaluating SleepState [\_S1_]
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- ****Exception****: AE_NOT_FOUND
for state S[1] , typea8 , typeb=7
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0150 [E000000185900000] [02] get_sleep_type_data   : AE_NOT_FOUND while evaluating SleepState [\_S2_]
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- ****Exception****: AE_NOT_FOUND
for state S[2] , typea8 , typeb=7
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0150 [E000000185900000] [02] get_sleep_type_data   : AE_NOT_FOUND while evaluating SleepState [\_S3_]
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- ****Exception****: AE_NOT_FOUND
for state S[3] , typea8 , typeb=7
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0150 [E000000185900000] [02] get_sleep_type_data   : AE_NOT_FOUND while evaluating SleepState [\_S4_]
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- ****Exception****: AE_NOT_FOUND
for state S[4] , typea8 , typeb=7
  hwregs-0125 [E000000185900000] [02] get_sleep_type_data   : ----Entry
  hwregs-0218 [E000000185900000] [02] get_sleep_type_data   : ----Exit- AE_OK
for state S[5] , typea=7 , typeb=7
 hwsleep-0244 [E000000185900000] [01] enter_sleep_state_prep: ----Exit- AE_OK




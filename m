From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Mon, 11 Dec 2006 07:17:26 +0000
Subject: Re: [PATCH 2/5] Itanium MC Error Injection Tool: Doc and sample
Message-Id: <1165821446.15989.105.camel@ymzhang>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161422.A1100@unix-os.sc.intel.com>
In-Reply-To: <20061208161422.A1100@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-12-08 at 16:14 -0800, Fenghua Yu wrote:
> This patch contains a documention and sample application. Since the sample
> application has ~1000 lines of code, it might not be suitable in a kernel
> documention in kenrel tree. If you think this is not good place to hold
> the sample application, please let me know and I'm open to other choices
> e.g. sourceforge etc.
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
> +
> +typedef union err_type_info_u {
> +	struct {
> +		u64	mode		: 3,	/* 0-2 */
> +			err_inj		: 3,	/* 3-5 */
> +			err_sev		: 2,	/* 6-7 */
> +			err_struct	: 5,	/* 8-12 */
> +			struct_hier	: 3,	/* 13-15 */
> +			reserved	: 48;	/* 16-63 */
> +	} err_type_info_u;
> +	u64	err_type_info;
> +} err_type_info_t;
> +
> +typedef union err_struct_info_u {
> +	struct {
> +		u64	siv		: 1,	/* 0	 */
> +			c_t		: 2,	/* 1-2	 */
> +			cl_p		: 3,	/* 3-5	 */
> +			cl_id		: 3,	/* 6-8	 */
> +			cl_dp		: 1,	/* 9	 */
> +			reserved1	: 22,	/* 10-31 */
> +			tiv		: 1,	/* 32	 */
> +			trigger		: 4,	/* 33-36 */
> +			trigger_pl 	: 3,	/* 37-39 */
> +			reserved2 	: 24;	/* 40-63 */
> +	} err_struct_info_cache;
> +	struct {
> +		u64	siv		: 1,	/* 0	 */
> +			tt		: 2,	/* 1-2	 */
> +			tc_tr		: 2,	/* 3-4	 */
> +			tr_slot		: 8,	/* 5-12	 */
> +			reserved1	: 19,	/* 13-31 */
> +			tiv		: 1,	/* 32	 */
> +			trigger		: 4,	/* 33-36 */
> +			trigger_pl 	: 3,	/* 37-39 */
> +			reserved2 	: 24;	/* 40-63 */
> +	} err_struct_info_tlb;
> +	struct {
> +		u64	siv		: 1,	/* 0	 */
> +			regfile_id	: 4,	/* 1-4	 */
> +			reg_num		: 7,	/* 5-11	 */
> +			reserved1	: 20,	/* 12-31 */
> +			tiv		: 1,	/* 32	 */
> +			trigger		: 4,	/* 33-36 */
> +			trigger_pl 	: 3,	/* 37-39 */
> +			reserved2 	: 24;	/* 40-63 */
> +	} err_struct_info_register;
> +	struct {
> +		u64	reserved;
> +	} err_struct_info_bus_processor_interconnect;
> +	u64	err_struct_info;
> +} err_struct_info_t;
> +
> +typedef union err_data_buffer_u {
> +	struct {
> +		u64	trigger_addr;		/* 0-63		*/
> +		u64	inj_addr;		/* 64-127 	*/
> +		u64	way		: 5,	/* 128-132	*/
> +			index		: 20,	/* 133-152	*/
> +					: 39;	/* 153-191	*/
> +	} err_data_buffer_cache;
> +	struct {
> +		u64	trigger_addr;		/* 0-63		*/
> +		u64	inj_addr;		/* 64-127 	*/
> +		u64	way		: 5,	/* 128-132	*/
> +			index		: 20,	/* 133-152	*/
> +			reserved	: 39;	/* 153-191	*/
> +	} err_data_buffer_tlb;
> +	struct {
> +		u64	trigger_addr;		/* 0-63		*/
> +	} err_data_buffer_register;
> +	struct {
> +		u64	reserved;		/* 0-63		*/
> +	} err_data_buffer_bus_processor_interconnect;
> +	u64 err_data_buffer[ERR_DATA_BUFFER_SIZE];
> +} err_data_buffer_t;
> +
> +typedef union capabilities_u {
> +	struct {
> +		u64	i		: 1,
> +			d		: 1,
> +			rv		: 1,
> +			tag		: 1,
> +			data		: 1,
> +			mesi		: 1,
> +			dp		: 1,
> +			reserved1	: 3,
> +			pa		: 1,
> +			va		: 1,
> +			wi		: 1,
> +			reserved2	: 20,
> +			trigger		: 1,
> +			trigger_pl	: 1,
> +			reserved3	: 30;
> +	} capabilities_cache;
> +	struct {
> +		u64	d		: 1,
> +			i		: 1,
> +			rv		: 1,
> +			tc		: 1,
> +			tr		: 1,
> +			reserved1	: 27,
> +			trigger		: 1,
> +			trigger_pl	: 1,
> +			reserved2	: 30;
> +	} capabilities_tlb;
> +	struct {
> +		u64	gr_b0		: 1,
> +			gr_b1		: 1,
> +			fr		: 1,
> +			br		: 1,
> +			pr		: 1,
> +			ar		: 1,
> +			cr		: 1,
> +			rr		: 1,
> +			pkr		: 1,
> +			dbr		: 1,
> +			ibr		: 1,
> +			pmc		: 1,
> +			pmd		: 1,
> +			reserved1	: 3,
> +			regnum		: 1,
> +			reserved2	: 15,
> +			trigger		: 1,
> +			trigger_pl	: 1,
> +			reserved3	: 30;
> +	} capabilities_register;
> +	struct {
> +		u64	reserved;
> +	} capabilities_bus_processor_interconnect;
> +} capabilities_t;
> +
> +typedef struct resources_s {
> +	u64	ibr0		: 1,
> +		ibr2		: 1,
> +		ibr4		: 1,
> +		ibr6		: 1,
> +		dbr0		: 1,
> +		dbr2		: 1,
> +		dbr4		: 1,
> +		dbr6		: 1,
> +		reserved	: 48;
> +} resources_t;
Is it better to move above definitions to file include/asm-ia64/pal.h?

From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 13 Aug 2004 18:15:24 +0000
Subject: Re: [PATCH] add coherence id for SGI Altix systems
Message-Id: <20040813191524.A13892@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131756.i7DHuWNi036140@shaft.americas.sgi.com>
In-Reply-To: <200408131756.i7DHuWNi036140@shaft.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 13, 2004 at 12:56:32PM -0500, Dean Roe wrote:
> +static int coherence_id_read_proc(char *page, char **start, off_t off,
> +		int count, int *eof, void *data) {

The { needs to go on a new line

> +	return sprintf(page, "%d\n", cpuid_to_coherence_id(smp_processor_id()));
> +}

please use the seq_file api.

> +void
> +register_sn_coherence_id(void) {

{ pleasement again, and this should be static.

> +	struct proc_dir_entry *entry;
> +
> +	if (!sgi_proc_dir) {
> +		sgi_proc_dir = proc_mkdir("sgi_sn", 0);
> +	}

don't SN2 systems have this directory already?

> +		entry->nlink = 1;
> +		entry->data = 0;

no need to set this two.

> +		entry->write_proc = NULL;

dito.


also while you're at it convert the whole file to seq_file and proper
coding style.

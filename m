From: Keith Owens <kaos@sgi.com>
Date: Tue, 21 Oct 2003 00:12:55 +0000
Subject: Re: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106669550812836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106664704821234@msgid-missing>
In-Reply-To: <marc-linux-ia64-106664704821234@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 20 Oct 2003 17:38:42 -0600, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Monday 20 October 2003 4:47 am, Keith Owens wrote:
>> I have reworked salinfo.c to get a clean separation between the
>> interrupt handler that is called from mca.c and the rest of the salinfo
>> code that runs in user context.
>
>Thanks for doing all this work.  You've obviously done a lot of work
>and I'm still going through it :-)
>
>The only comment/question I have so far is about the log_buffer
>management.  You're relying on ia64_sal_get_state_info_size(X)
>returning the same thing every time it's called for "X".  I seem
>to recall some weaseling on the part of our FW guys, because
>they might want to change the size based on hot-plug events.
>But I don't think the spec really leaves them that option.

I was worried about that myself but, as you say, the spec has no room
for changing record sizes.  SAL has to return one maximum size for all
records of that type for this boot.

>In any case, since we do rely on the size being constant, what
>about doing the allocation in sal_log_open()?  Then it could be
>removed from salinfo_log_read() and salinfo_log_clear(), and the
>open/release paths would be more parallel.

Sounds good.

>I'm not too sure about the vfree() in salinfo_exit().  As you say,
>it can't be built as a module, even if it could be, there should
>be some mechanism that prevents the module from being unloaded
>while any of the files are open.

Agreed.  salinfo.c cannot be a module and salinfo_exit() should
disappear.  I left it in until I got a second opinion.


One minor bug, salinfo_log_wakeup() must not call shift1_data_saved()
if data->saved_num is non-zero.  While the user context code is reading
a saved record, the interrupt handler can use a free saved slot but it
cannot change the slots that are in use.

        if (i = saved_size) {  
                if (!data->saved_num) {
                        shift1_data_saved(data, 0);
                        data_saved = data->data_saved + saved_size - 1;
                } else 
                        data_saved = NULL;
        }
        if (data_saved) {
                data_saved->cpu = smp_processor_id();
                data_saved->id = ((sal_log_record_header_t *)buffer)->id;
                data_saved->size = size;
                data_saved->buffer = buffer;
        }



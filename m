From: Mario Smarduch <cms063@email.mot.com>
Date: Mon, 28 Oct 2002 16:14:30 +0000
Subject: [Linux-ia64] Re: Fixing /proc/kcore
Message-Id: <marc-linux-ia64-105590709805276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805249@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805249@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, Andi thanks!

- mario

Andi Kleen wrote:

> "Luck, Tony" <tony.luck@intel.com> writes:
>
> > This message is in MIME format. Since your mail reader does not understand
> > this format, some or all of this message may not be legible.
> >
> > ------_=_NextPart_000_01C27C4E.CD496DB0
> > Content-Type: text/plain;
> >       charset="utf-7"
> >
> > /proc/kcore is what you need, but it is broken on ia64 (and
> > has been since the dawn of time for access to region 5) because
> > it assumes that all kernel virtual addresses are above PAGE_OFFSET.
> > This isn't true on ia64, VMALLOC_START is smaller than PAGE_OFFSET.
>
> I recently fixed a similar problem on x86-64. There the modules are outside
> the vmalloc area, but also not in the direct mapping. I just changed
> the module mapping and the kernel mapping to put themselves into the vmlist.
> kcore checks vmlist first and then afterwards tries direct addresses.
>
> Also the kernel addresses are negative, which needed some more changes
> in seek.
>
> Here is the 2.4.19 patch which should to 2.5 too.
>
> I think it's a bit cleaner than yours and will probably help you too.
> Just put everything special into vmlist too.
>
> -Andi
>
> Index: linux/fs/proc/inode.c
> =================================> RCS file: /home/cvs/Repository/linux/fs/proc/inode.c,v
> retrieving revision 1.4
> retrieving revision 1.5
> diff -u -u -r1.4 -r1.5
> --- linux/fs/proc/inode.c       2002/01/15 10:09:21     1.4
> --- linux/fs/proc/inode.c       2002/10/17 13:02:13     1.5
> @@ -186,6 +184-,7 @@
>         s->s_blocksize_bits = 10;
>         s->s_magic = PROC_SUPER_MAGIC;
>         s->s_op = &proc_sops;
>         s->s_maxbytes = +AH4-0ULL;
>
>         root_inode = proc_get_inode(s, PROC_ROOT_INO, &proc_root);
>         if (!root_inode)
> Index: linux/fs/proc/kcore.c
> =================================> RCS file: /home/cvs/Repository/linux/fs/proc/kcore.c,v
> retrieving revision 1.3
> retrieving revision 1.4
> diff -u -u -r1.3 -r1.4
> --- linux/fs/proc/kcore.c       2002/03/21 11:54:59     1.3
> --- linux/fs/proc/kcore.c       2002/10/17 13:02:13     1.4
> @@ -27,11 ,14 @@
>         return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
>  }
>
> +statiQ- loff_t lseek_kcore(struct file * file, loff_t offset, int origin);
>
>  static ssize_t read_kcore(struct file *, char *, size_t, loff_t *);
>
>  struct file_operations proc_kcore_operations = {
>         read:           read_kcore,
>         open:           open_kcore,
>         lseek:          lseek_kcore,
>  };
>
>  #ifdef CONFIG_KCORE_AOUT
> @@ -112,9 +114-,9 @@
>
>  extern char saved_command_line[];
>
> -static size_t get_kcore_size(int *num_vma, size_t *elf_buflen)
> +statiQ- unsigned long get_kcore_size(int *num_vma, size_t *elf_buflen)
>  {
> -       size_t try, size;
>         unsigned long try, size;
>         struct vm_struct *m;
>
>         *num_vma = 0;
> @@ -125,7 +128-,7 @@
>         }
>
>         for (m=vmlist; m; m=m->next) {
> -               try = (size_t)m->addr  m->size;
>                 try = (unsigned long)m->addr  m->size;
>                 if (try > size)
>                         size = try;
>                 *num_vma = *num_vma  1;
> @@ -313,14 +314-,14 @@
>  static ssize_t read_kcore(struct file *file, char *buffer, size_t buflen, loff_t *fpos)
>  {
>         ssize_t acc = 0;
> -       size_t size, tsz;
>         unsigned long size, tsz;
>         size_t elf_buflen;
>         int num_vma;
>         unsigned long start;
>
>         read_lock(&vmlist_lock);
>         proc_root_kcore->size = size = get_kcore_size(&num_vma, &elf_buflen);
> -       if (buflen = 0 || *fpos >= size) {
>         if (buflen = 0 || (unsigned long long)*fpos >= size) {
>                 read_unlock(&vmlist_lock);
>                 return 0;
>         }
> @@ -390,9 +390-,16 @@
>         start = PAGE_OFFSET  (*fpos - elf_buflen);
>         if ((tsz = (PAGE_SIZE - (start & +AH4-PAGE_MASK))) > buflen)
>                 tsz = buflen;
> -
>         while (buflen) {
> -               if ((start >= VMALLOC_START) && (start < VMALLOC_END)) {
>                 int err;
>
>                 if ((start > PAGE_OFFSET) && (start < (unsigned long)high_memory)) {
>                         if (kern_addr_valid(start)) {
>                                 err = copy_to_user(buffer, (char *)start, tsz);
>                         } else {
>                                 err = clear_user(buffer, tsz);
>                         }
>                 } else {
>                         char * elf_buf;
>                         struct vm_struct *m;
>                         unsigned long curstart = start;
> @@ -432,24 +440-,11 @@
>                                         (char *)vmstart, vmsize);
>                         }
>                         read_unlock(&vmlist_lock);
> -                       if (copy_to_user(buffer, elf_buf, tsz)) {
> -                               kfree(elf_buf);
> -                               return -EFAULT;
> -                       }
>                         err = copy_to_user(buffer, elf_buf, tsz);
>                         kfree(elf_buf);
> -               } else if ((start > PAGE_OFFSET) && (start <
> -                                               (unsigned long)high_memory)) {
> -                       if (kern_addr_valid(start)) {
> -                               if (copy_to_user(buffer, (char *)start, tsz))
> -                                       return -EFAULT;
> -                       } else {
> -                               if (clear_user(buffer, tsz))
> -                                       return -EFAULT;
> -                       }
> -               } else {
> -                       if (clear_user(buffer, tsz))
> -                               return -EFAULT;
> -               }
>                 }
>                 if (err)
>                         return -EFAULT;
>                 buflen -= tsz;
>                 *fpos = tsz;
>                 buffer = tsz;
> @@ -461,3 +458-,19 @@
>         return acc;
>  }
>  #endif /* CONFIG_KCORE_AOUT */
>
> +statiQ- loff_t lseek_kcore(struct file * file, loff_t offset, int origin)
> {
>         long long retval;
>
>         switch (origin) {
>                 case 2:
>                         offset = file->f_dentry->d_inode->i_size;
>                         break;
>                 case 1:
>                         offset = file->f_pos;
>         }
>         /* RED-PEN user can fake an error here by setting offset to >=-4095 && <0  */
>         file->f_pos = offset;
>         return offset;
> }



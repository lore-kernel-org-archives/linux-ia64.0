From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 29 Aug 2003 22:17:17 +0000
Subject: Re: [PATCH] efivars update
Message-Id: <marc-linux-ia64-106219548517935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106219352715985@msgid-missing>
In-Reply-To: <marc-linux-ia64-106219352715985@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> The patch is against 2.6.0-test4.=A0 Please apply.=A0

Thanks for your work on this!  One bug, 3 nits...

> +static ssize_t
> +efivar_edit(struct efivar_entry *entry, const char *buf, size_t count)
...
> +=A0=A0=A0=A0=A0=A0 spin_lock(&efivars_lock);
> +=A0=A0=A0=A0=A0=A0 status =3D efi.set_variable(new_var->VariableName,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 &new_var->VendorGuid,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 new_var->Attributes,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 new_var->DataSize,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 new_var->Data);
> +
> +=A0=A0=A0=A0=A0=A0 if (status !=3D EFI_SUCCESS) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 printk(KERN_WARNING "set_variab=
le() failed: status=3D%lx\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 status);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EIO;
> +=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 spin_unlock(&efivars_lock);


Move the unlock up above the status test, else you return while
holding the lock on failure.


> +static ssize_t
> +efivar_create(struct subsystem *sub, const char *buf, size_t count)
...
> +=A0=A0=A0=A0=A0=A0 if (found) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 printk("EFI variable already ex=
ists!\n");

level on printk please.



> +efivar_delete(struct subsystem *sub, const char *buf, size_t count)
...
> +=A0=A0=A0=A0=A0=A0 status =3D efi.set_variable(del_var->VariableName,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 &del_var->VendorGuid,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 del_var->Attributes,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 del_var->DataSize,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0 del_var->Data);

Might as well just force the deletion by setting Attributes=3D0 or
DataSize=3D0 or both.  Less chance for userspace error.


> + * Overrides for Emacs so that we follow Linus's tabbing style.

Please kill this chunk.  I shouldn't have had it there in the first=20
place. :-)

Looks great to me!  Thanks again.


--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com



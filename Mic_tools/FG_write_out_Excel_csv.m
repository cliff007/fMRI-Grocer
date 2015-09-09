function FG_write_out_Excel_csv(write_name,matrix)
        csvwrite(FG_check_and_rename_existed_file(write_name),matrix)  
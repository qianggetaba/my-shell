

binlog_file=binlog.000003
binlogsql_file=sql${binlog_file}.sql
in_sql=false
in_ddl=false
one_sql=""
line_break='
'
sql_count=0


function real_sql(){
    if [[ -z "$one_sql" ]];then
        return 1
    fi
    one_sql_content=`printf "$one_sql"|sed 's/### //g'`
    echo "sql content:$one_sql_content"
    table_name=`printf "$one_sql_content" |grep INSERT |sed 's/INSERT INTO //'`
    echo "table name after insert:$table_name"
    if [[ -z "$table_name" ]];then
        table_name=`printf "$one_sql_content" |grep UPDATE |sed 's/UPDATE //'`
        echo "table name after update:$table_name"
    fi
    if [[ -z "$table_name" ]];then
        table_name=`printf "$one_sql_content" |grep DELETE |sed 's/DELETE FROM //'`
        echo "table name after delete:$table_name"
    fi
    if [[ -z "$table_name" ]];then
        echo "table_name not found:$one_sql"
        one_sql_real=${one_sql}
        return 1
    fi

    echo "table_name:$table_name"
    # get all column names of the table, and replace @ with column name
    columns=$(mysql -e "desc ${table_name}" |grep -v "+-" |grep -v "Field"|awk '{print $1}')
    echo "columns:$columns"
    count=0
    for column in $columns
    do
        (( count++ ))
        one_sql_content=`printf "$one_sql_content" | sed -e "s/@$count/$column/g"`
    done
    one_sql_real="$one_sql_content ;"
    # printf "$one_sql_real"
}

function save_sql(){
    real_sql
    printf "${one_sql_real}${line_break}" >> $binlogsql_file
    echo "one sql save:$one_sql_real"
    
    one_sql=""
    in_sql=false
    ((sql_count++))
    echo "sql count:$sql_count"

    if [[ $sql_count == 200 ]];then
        exit 0
    fi
}

while IFS= read -r line
do
    echo "current binlog line:$line"
    # drop，create是单行或多行语句，完成后的下一行是 /*!*/;
    if [[ ("$line" =~ ^CREATE*) || ("$line" =~ ^create*) || ("$line" =~ ^DROP*) || ("$line" =~ ^drop*) ]]; then
        echo "sql create or drop start:${line}"
        one_sql="${line}"
        in_sql=true
        in_ddl=true
        continue
    fi
    if [[ ("$line" == '/*!*/;') && ("$in_sql" == true) ]]; then
        echo "sql create or drop end:${line}"
        in_ddl=false
        save_sql
        continue
    fi
    if [[ ( ! "$line" =~ ^###.*) && ("$in_ddl" == true) ]];then
        echo "sql create or drop append:${line}"
        one_sql="${one_sql}${line_break}${line}"
        continue
    fi

    # 其他dml语句是以###开头，可能会几个sql在一起，注意正确识别一条完整sql
    # 判断一条sql结束，1. 下一行不以###开始 2. 下一行是另一条sql开始
    if [[ "$line" =~ ^###.* ]]; then
        echo "find sql:$line"
        # 判断是否下一个sql的开始, 保存上一个sql
        if [ "$in_sql" = true ] ; then
            line_content=`echo $line |sed 's/^### //'`
            if [[ ("$line_content" =~ ^INSERT*) || ("$line_content" =~ ^UPDATE*) || ("$line_content" =~ ^DELETE*) ]]; then
                echo "another sql started, save last one"
                save_sql
            fi
        fi
        if [ "$in_sql" = false ] ; then
            echo "new sql started:${line}"
            in_sql=true
            one_sql="${line}"
        else
            echo "sql append(dml):${line}"
            one_sql="${one_sql}${line_break}${line}"
        fi
        continue
    else
        if [ "$in_sql" = true ] ; then
            echo "not sql line, save last sql"
            save_sql
        fi
    fi
    if [[ ("$in_sql" == true) ]]; then
        echo "sql append(in_sql true):${line}"
        one_sql="${one_sql}${line_break}${line}"
    fi
done < <(mysqlbinlog -v --base64-output=decode-rows $binlog_file)

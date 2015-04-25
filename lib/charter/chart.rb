class Charter::Chart
  class << self
    def draw(data, options={})
      options = {type: 'BubbleChart'}.merge(options)
      if options[:container]
        script(data, options)
      else
        id = Time.now.to_f.to_s
        "<div id='#{id}'></div>#{script(data, {container: id}.merge(options))}"
      end.html_safe
    end

    private
      def script(data, options)
<<SCRIPT
<script>
  google.load('visualization', '1', {packages: ['corechart']});
  google.setOnLoadCallback(function chart(){
    var data = new google.visualization.DataTable(#{convert(data, options[:header])});
    (new google.visualization.#{options[:type]}(document.getElementById('#{options[:container]}')))
    .draw(data, #{(options[:options] || {}).to_json});
  });
</script>
SCRIPT
      end

      def convert(data, mheader)
        return {cols: [], rows: []}.to_json if data.empty?
        mheader ||= {}
        header = []
        data[0].each_with_index do |e, i|
          header << case e
          when DateTime, Time
            {id: i, label: mheader[i] || 'DateTime', type: 'datetime'}
          when BigDecimal, Float, Integer
            {id: i, label: mheader[i] || 'Number', type: 'number'}
          else
            {id: i, label: mheader[i] || 'String', type: 'string'}
          end
        end
        res = data.map do |row|
          {c: row.map do |e|
                {v: case e
                    when Time
                      "Date(#{e.year}, #{e.month}, #{e.day}, #{e.hour}, #{e.min}, #{e.sec})"
                    when DateTime
                      "Date(#{e.year}, #{e.month}, #{e.day}, #{e.hour}, #{e.minute}, #{e.second})"
                    when BigDecimal
                      e.to_f
                    else
                      e
                    end
                }
              end
            }
        end
        {cols: header, rows: res}.to_json
      end
    end
end
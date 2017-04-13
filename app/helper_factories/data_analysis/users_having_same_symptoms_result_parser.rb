class DataAnalysis::UsersHavingSameSymptomsResultParser
  def self.parse_result(analysis)
    output_path = "./data-analysis-fimi03/outputs/#{analysis.token}.output"
    results = []
    open(output_path) do |file|
      lines = file.readlines
      lines.each do |line|
        number_of_match = line.scan(/.*\((\d+)/).last.first
        symptoms = []
        line.scan(/(\d+)\s/).each do |match|
          symptoms << Symptom.find(match.first)
        end
        symptoms.sort!
        result = {number_of_match: number_of_match, symptoms: symptoms}
        results << result
      end
    end
    results
  end
end
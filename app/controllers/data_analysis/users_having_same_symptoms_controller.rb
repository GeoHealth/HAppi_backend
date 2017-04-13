class DataAnalysis::UsersHavingSameSymptomsController < ApplicationController
  def index
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.all
  end

  def new
  end

  def create
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new(analysis_params)
    @analysis.status = 'created'
    if @analysis.save
      DataAnalysis::AnalysisUsersHavingSameSymptomWorker.perform_async(@analysis.id)
      redirect_to action: 'show', id: @analysis.id
    else
      render plain: @analysis.errors.inspect, status: 404
    end
  end

  def show
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.find(params[:id])
    if @analysis.status == 'done'
      output_path = "./data-analysis-fimi03/outputs/#{@analysis.token}.output"
      @results = []
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
          @results << result
        end
      end
    end
  end

  private
  def analysis_params
    params.require(:analysis).permit(:start_date, :end_date, :threshold)
  end
end
